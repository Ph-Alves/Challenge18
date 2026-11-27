//
//  WatchConnectivityTests.swift
//  ChallengeFinalWatch Watch AppTests
//
//  Created by Paulo Henrique Costa Alves on 26/11/26.
//

import Testing
import Foundation
@testable import ChallengeFinalWatch_App

// MARK: - Test doubles

/// Presenter falso: só conta o que interessa a estes testes.
@MainActor
final class WatchPresenterSpy: WatchPresenterProtocol {

    private(set) var completedCount = 0

    func presentCompleted() { completedCount += 1 }

    // Fora do escopo destes testes
    func presentHome() {}
    func presentDraw() {}
    func presentChallenge() {}
    func presentAccepted() {}
    func presentInProgress() {}
    func presentCategory(_ category: WatchCategory) {}
    func presentDrawnChallenge(_ challenge: WatchChallenge) {}
    func presentAchievement(_ achievement: WatchAchievement) {}
    func presentTime(_ elapsed: TimeInterval) {}
    func presentPaused(_ isPaused: Bool) {}
}

/// Sorteio falso: devolve sempre o mesmo desafio e a mesma conquista (ou `nil`, para simular a falta deles).
@MainActor
final class WatchPresetWorkerStub: WatchPresetWorkerProtocol {

    var challenge: WatchChallenge?
    var achievementToReturn: WatchAchievement?

    /// Tempos com que o Interactor pediu a conquista.
    private(set) var requestedElapsed: [TimeInterval] = []

    init(challenge: WatchChallenge? = .sample, achievement: WatchAchievement? = .sample) {
        self.challenge = challenge
        self.achievementToReturn = achievement
    }

    func draw(for category: WatchCategory) -> WatchChallenge? { challenge }

    func achievement(elapsed: TimeInterval) -> WatchAchievement? {
        requestedElapsed.append(elapsed)
        return achievementToReturn
    }
}

/// Cronômetro falso: o fluxo de ticks termina na hora, então nenhum teste fica esperando segundos.
@MainActor
struct WatchTimerWorkerStub: WatchTimerWorkerProtocol {
    func ticks() -> AsyncStream<Void> {
        AsyncStream { $0.finish() }
    }
}

/// Movimento falso: não liga o acelerômetro.
@MainActor
final class WatchMotionWorkerStub: WatchMotionWorkerProtocol {
    var onShake: (() -> Void)?
    func startMonitoring() {}
    func stopMonitoring() {}
}

/// Conexão falsa com o iPhone: anota o que seria enviado, sem `WCSession`.
@MainActor
final class WatchConnectivitySpy: WatchConnectivityWorkerProtocol {

    private(set) var activateCount = 0
    private(set) var sent: [WatchActivityPayload] = []

    func activate() { activateCount += 1 }
    func send(_ payload: WatchActivityPayload) { sent.append(payload) }
}

extension WatchChallenge {
    static let sample = WatchChallenge(
        title: "faça o seu cárdio sem abrir redes sociais",
        subTitle: "Cardio sem fones",
        rationale: "Corra por 20 minutos sem olhar o celular."
    )
}

extension WatchAchievement {
    static let sample = WatchAchievement(
        title: "Pé na estrada",
        description: "Você correu por 20 min sem distrações."
    )
}

// MARK: - WatchInteractor → iPhone

@Suite("WatchInteractor: envio da atividade concluída para o iPhone")
@MainActor
struct WatchInteractorConnectivityTests {

    // MARK: - Auxiliadores

    private struct Sut {
        let interactor: WatchInteractor
        let connectivity: WatchConnectivitySpy
        let presets: WatchPresetWorkerStub
        let presenter: WatchPresenterSpy
    }

    private func makeSut(
        challenge: WatchChallenge? = .sample,
        achievement: WatchAchievement? = .sample
    ) -> Sut {
        let connectivity = WatchConnectivitySpy()
        let presets = WatchPresetWorkerStub(challenge: challenge, achievement: achievement)
        let presenter = WatchPresenterSpy()
        let interactor = WatchInteractor(
            presenter: presenter,
            presetWorker: presets,
            timer: WatchTimerWorkerStub(),
            motion: WatchMotionWorkerStub(),
            connectivity: connectivity
        )
        return Sut(interactor: interactor, connectivity: connectivity, presets: presets, presenter: presenter)
    }

    /// Percorre o fluxo até o cronômetro rodando: categoria → sorteio → aceitar → iniciar.
    private func playUntilTimerRuns(_ sut: Sut, category: WatchCategory = .physical) {
        sut.interactor.startActivity(category: category)
        sut.interactor.finishDraw()
        sut.interactor.acceptChallenge()
        sut.interactor.startTimer()
    }

    // MARK: - Ativação

    @Test("liga a sessão com o iPhone ao criar o Interactor")
    func activatesConnectivityOnInit() {
        let sut = makeSut()

        #expect(sut.connectivity.activateCount == 1)
    }

    // MARK: - Envio

    @Test("ao parar o cronômetro, manda uma atividade com os dados do desafio")
    func finishActivitySendsChallengeData() throws {
        let sut = makeSut()
        playUntilTimerRuns(sut, category: .cognitive)

        sut.interactor.finishActivity()

        let payload = try #require(sut.connectivity.sent.first)
        #expect(sut.connectivity.sent.count == 1)
        #expect(payload.category == "cognitive")
        #expect(payload.title == WatchChallenge.sample.title)
        #expect(payload.subTitle == WatchChallenge.sample.subTitle)
        #expect(payload.achievementTitle == WatchAchievement.sample.title)
        #expect(payload.achievementDescription == WatchAchievement.sample.description)
    }

    @Test("a categoria enviada é a escolhida na home", arguments: WatchCategory.allCases)
    func payloadCarriesSelectedCategory(category: WatchCategory) throws {
        let sut = makeSut()
        playUntilTimerRuns(sut, category: category)

        sut.interactor.finishActivity()

        #expect(try #require(sut.connectivity.sent.first).category == category.rawValue)
    }

    @Test("o tempo enviado é o mesmo usado para pedir a conquista")
    func payloadTimeMatchesAchievementTime() throws {
        let sut = makeSut()
        playUntilTimerRuns(sut)

        sut.interactor.finishActivity()

        let payload = try #require(sut.connectivity.sent.first)
        #expect(sut.presets.requestedElapsed == [payload.time])
        #expect(payload.time >= 0)
    }

    @Test("sem conquista disponível, manda os textos da conquista vazios")
    func missingAchievementSendsEmptyTexts() throws {
        let sut = makeSut(achievement: nil)
        playUntilTimerRuns(sut)

        sut.interactor.finishActivity()

        let payload = try #require(sut.connectivity.sent.first)
        #expect(payload.achievementTitle.isEmpty)
        #expect(payload.achievementDescription.isEmpty)
    }

    @Test("parar o cronômetro ainda leva ao \"arrasou\"")
    func finishActivityStillPresentsCompleted() {
        let sut = makeSut()
        playUntilTimerRuns(sut)

        sut.interactor.finishActivity()

        #expect(sut.presenter.completedCount == 1)
    }

    // MARK: - Sem envio

    @Test("o X do \"arrasou\" chama finishActivity de novo, mas não reenvia a atividade")
    func finishingTwiceSendsOnlyOnce() {
        let sut = makeSut()
        playUntilTimerRuns(sut)

        sut.interactor.finishActivity()
        sut.interactor.finishActivity()

        #expect(sut.connectivity.sent.count == 1)
    }

    @Test("fechar no meio do desafio descarta a atividade")
    func closingBeforeFinishSendsNothing() {
        let sut = makeSut()
        playUntilTimerRuns(sut)

        sut.interactor.didTapClose()
        sut.interactor.finishActivity()

        #expect(sut.connectivity.sent.isEmpty)
    }

    @Test("sem ter iniciado o cronômetro, não há atividade para enviar")
    func finishingWithoutStartingSendsNothing() {
        let sut = makeSut()

        sut.interactor.finishActivity()

        #expect(sut.connectivity.sent.isEmpty)
    }

    @Test("sem desafio sorteado, não há atividade para enviar")
    func finishingWithoutChallengeSendsNothing() {
        let sut = makeSut(challenge: nil)
        playUntilTimerRuns(sut)

        sut.interactor.finishActivity()

        #expect(sut.connectivity.sent.isEmpty)
    }

    // MARK: - Várias atividades

    @Test("cada atividade tem um id próprio, que é o que o iPhone usa para evitar duplicata")
    func eachActivityGetsItsOwnID() {
        let sut = makeSut()

        playUntilTimerRuns(sut)
        sut.interactor.finishActivity()
        playUntilTimerRuns(sut)
        sut.interactor.finishActivity()

        #expect(sut.connectivity.sent.count == 2)
        #expect(Set(sut.connectivity.sent.map(\.id)).count == 2)
    }
}

// MARK: - WatchActivityPayload

@Suite("WatchActivityPayload: formato que viaja para o iPhone")
struct WatchActivityPayloadTests {

    private let payload = WatchActivityPayload(
        id: UUID(),
        category: "physical",
        title: "faça o seu cárdio sem abrir redes sociais",
        subTitle: "Cardio sem fones",
        time: 125.5,
        completedAt: Date(timeIntervalSince1970: 1_700_000_000),
        achievementTitle: "Pé na estrada",
        achievementDescription: "Você correu por 20 min."
    )

    @Test("o que sai pelo asUserInfo volta igual pelo init(userInfo:)")
    func roundTrip() throws {
        let userInfo = try payload.asUserInfo()

        #expect(WatchActivityPayload(userInfo: userInfo) == payload)
    }

    @Test("o dicionário só leva Data, que é um tipo aceito pelo WCSession")
    func userInfoHoldsOnlyData() throws {
        let userInfo = try payload.asUserInfo()

        #expect(userInfo.count == 1)
        #expect(userInfo[WatchActivityPayload.userInfoKey] is Data)
    }

    @Test("um dicionário que não é deste app não vira payload")
    func foreignUserInfoReturnsNil() {
        #expect(WatchActivityPayload(userInfo: [:]) == nil)
        #expect(WatchActivityPayload(userInfo: ["outraChave": "valor"]) == nil)
    }

    @Test("bytes que não são um payload não viram payload")
    func corruptDataReturnsNil() {
        let userInfo: [String: Any] = [WatchActivityPayload.userInfoKey: Data("não é json".utf8)]

        #expect(WatchActivityPayload(userInfo: userInfo) == nil)
    }

    /// O iPhone converte esse texto em `ActivityCategory`. Se um case mudar de nome de um lado só,
    /// a atividade seria recusada: este teste (e o espelho dele no target iOS) trava esse contrato.
    @Test("os rawValues das categorias do Watch são os que o iPhone espera")
    func categoryRawValuesMatchTheiPhoneContract() {
        #expect(Set(WatchCategory.allCases.map(\.rawValue)) == ["physical", "cognitive", "sensorial", "social"])
    }
}
