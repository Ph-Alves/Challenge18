//
//  WatchConnectivityTests.swift
//  ChallengeFinalTests
//
//  Created by Paulo Henrique Costa Alves on 26/11/26.
//

import Testing
import SwiftData
import Foundation
import WatchConnectivity
@testable import ChallengeFinal

// MARK: - WatchActivityImporter

@Suite("WatchActivityImporter: grava no banco a atividade concluída no Watch")
@MainActor
struct WatchActivityImporterTests {

    // MARK: - Auxiliadores

    let modelContainer: ModelContainer = {
        let schema = Schema([Activity.self, ActivityResult.self, Profile.self])
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        return try! ModelContainer(for: schema, configurations: config)
    }()

    private func makeImporter() -> WatchActivityImporter {
        WatchActivityImporter(context: modelContainer.mainContext)
    }

    private func savedActivities() throws -> [Activity] {
        try GenericRepository<Activity>(context: modelContainer.mainContext).getAll()
    }

    private func makePayload(
        id: UUID = UUID(),
        category: String = "social"
    ) -> WatchActivityPayload {
        WatchActivityPayload(
            id: id,
            category: category,
            title: "ligue para alguém querido",
            subTitle: "Ligação sem pressa",
            time: 300,
            completedAt: Date(timeIntervalSince1970: 1_700_000_000),
            achievementTitle: "Voz amiga",
            achievementDescription: "Você conversou por 5 min."
        )
    }

    // MARK: - Gravação

    @Test("cria a Activity com os dados vindos do Watch")
    func importsActivityData() throws {
        let payload = makePayload(category: "cognitive")

        try makeImporter().importActivity(payload)

        let activity = try #require(try savedActivities().first)
        #expect(activity.category == .cognitive)
        #expect(activity.name == payload.title)
        #expect(activity.activityDescription == payload.subTitle)
        #expect(activity.createdAt == payload.completedAt)
        #expect(activity.archived == false)
    }

    @Test("cria o ActivityResult com tempo e conquista, sem humor nem foto")
    func importsResultData() throws {
        let payload = makePayload()

        try makeImporter().importActivity(payload)

        let result = try #require(try savedActivities().first?.result)
        #expect(result.time == payload.time)
        #expect(result.achievementTitle == payload.achievementTitle)
        #expect(result.achievementDescription == payload.achievementDescription)
        #expect(result.humor == nil)
        #expect(result.photo == nil)
    }

    @Test("o id do Watch vira o activityID")
    func keepsWatchIDAsActivityID() throws {
        let payload = makePayload()

        try makeImporter().importActivity(payload)

        #expect(try savedActivities().first?.activityID == payload.id)
    }

    // MARK: - Duplicatas

    @Test("receber a mesma atividade duas vezes grava só uma")
    func importingTheSamePayloadTwiceSavesOnce() throws {
        let payload = makePayload()
        let importer = makeImporter()

        try importer.importActivity(payload)
        try importer.importActivity(payload)

        #expect(try savedActivities().count == 1)
    }

    @Test("atividades com ids diferentes são gravadas separadas")
    func differentIDsAreSavedSeparately() throws {
        let importer = makeImporter()

        try importer.importActivity(makePayload())
        try importer.importActivity(makePayload())

        #expect(try savedActivities().count == 2)
    }

    // MARK: - Categoria

    @Test("categoria desconhecida é recusada e nada é gravado")
    func unknownCategoryThrowsAndSavesNothing() throws {
        #expect(throws: WatchActivityImporter.ImportError.self) {
            try makeImporter().importActivity(makePayload(category: "inexistente"))
        }

        #expect(try savedActivities().isEmpty)
    }

    /// Espelho do teste do Watch: são esses os textos que o `WatchCategory` envia. Se um case mudar
    /// de nome só de um lado, a atividade do Watch seria recusada.
    @Test("as quatro categorias do Watch são aceitas", arguments: ["physical", "cognitive", "sensorial", "social"])
    func watchCategoriesAreAccepted(category: String) throws {
        try makeImporter().importActivity(makePayload(category: category))

        #expect(try savedActivities().first?.category.rawValue == category)
    }
}

// MARK: - PhoneConnectivityWorker

@Suite("PhoneConnectivityWorker: recebe do Watch e manda gravar")
@MainActor
struct PhoneConnectivityWorkerTests {

    // MARK: - Auxiliadores

    let modelContainer: ModelContainer = {
        let schema = Schema([Activity.self, ActivityResult.self, Profile.self])
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        return try! ModelContainer(for: schema, configurations: config)
    }()

    /// Conta quantas vezes o worker avisou que gravou.
    private final class ImportCounter {
        var count = 0
    }

    private func makeWorker() -> (worker: PhoneConnectivityWorker, counter: ImportCounter) {
        let worker = PhoneConnectivityWorker(importer: WatchActivityImporter(context: modelContainer.mainContext))
        let counter = ImportCounter()
        worker.onImport = { counter.count += 1 }
        return (worker, counter)
    }

    private func savedActivities() throws -> [Activity] {
        try GenericRepository<Activity>(context: modelContainer.mainContext).getAll()
    }

    private func makePayload(category: String = "physical") -> WatchActivityPayload {
        WatchActivityPayload(
            category: category,
            title: "dê uma caminhada",
            subTitle: "Caminhada curta",
            time: 600,
            achievementTitle: "Pé na estrada",
            achievementDescription: "Você caminhou por 10 min."
        )
    }

    /// O worker grava numa `Task` depois de receber, então espera a condição ficar verdadeira.
    private func waitUntil(_ condition: () -> Bool) async {
        let deadline = ContinuousClock.now + .seconds(2)
        while !condition() && ContinuousClock.now < deadline {
            try? await Task.sleep(for: .milliseconds(10))
        }
    }

    // MARK: - Recebimento

    @Test("uma atividade recebida do Watch é gravada e avisa quem escuta")
    func receivedPayloadIsSavedAndNotified() async throws {
        let (worker, counter) = makeWorker()
        let payload = makePayload()

        worker.session(WCSession.default, didReceiveUserInfo: try payload.asUserInfo())
        await waitUntil { counter.count == 1 }

        #expect(counter.count == 1)
        #expect(try savedActivities().first?.activityID == payload.id)
    }

    @Test("a mesma atividade reentregue pelo sistema não duplica nem avisa de novo")
    func redeliveredPayloadIsNotDuplicated() async throws {
        let (worker, counter) = makeWorker()
        let userInfo = try makePayload().asUserInfo()

        worker.session(WCSession.default, didReceiveUserInfo: userInfo)
        await waitUntil { counter.count == 1 }
        worker.session(WCSession.default, didReceiveUserInfo: userInfo)
        try? await Task.sleep(for: .milliseconds(200))

        #expect(try savedActivities().count == 1)
    }

    @Test("um dicionário que não é do Watch deste app é ignorado")
    func foreignUserInfoIsIgnored() async throws {
        let (worker, counter) = makeWorker()

        worker.session(WCSession.default, didReceiveUserInfo: ["outraChave": "valor"])
        try? await Task.sleep(for: .milliseconds(200))

        #expect(counter.count == 0)
        #expect(try savedActivities().isEmpty)
    }

    @Test("uma atividade que não pôde ser gravada não avisa que gravou")
    func failedImportDoesNotNotify() async throws {
        let (worker, counter) = makeWorker()

        worker.session(WCSession.default, didReceiveUserInfo: try makePayload(category: "inexistente").asUserInfo())
        try? await Task.sleep(for: .milliseconds(200))

        #expect(counter.count == 0)
        #expect(try savedActivities().isEmpty)
    }
}
