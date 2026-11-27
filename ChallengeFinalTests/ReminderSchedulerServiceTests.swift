//
//  ReminderSchedulerServiceTests.swift
//  ChallengeFinalTests
//
//  Created by Débora Cristina Silva Ferreira on 27/11/26.
//

import Foundation
import SwiftData
import Testing
@testable import ChallengeFinal

// MARK: - Doubles (os Workers que o Service usa, sem tocar no sistema)

/// Worker de notificação falso: não pede permissão nem agenda nada de verdade, só anota as chamadas.
/// `@MainActor` porque o `NotificationWorkerProtocol` também é.
@MainActor
final class NotificationWorkerMock: NotificationWorkerProtocol {
    /// O que `requestAuthorization` devolve: `false` simula permissão negada.
    var granted = true
    var requestError: Error?
    var scheduleError: Error?
    private(set) var requestCount = 0
    /// O `skipToday` de cada `scheduleReminder`, na ordem das chamadas.
    private(set) var scheduleCalls: [Bool] = []
    private(set) var cancelCount = 0

    func requestAuthorization() async throws -> Bool {
        requestCount += 1
        if let requestError { throw requestError }
        return granted
    }

    func scheduleReminder(skipToday: Bool) async throws {
        scheduleCalls.append(skipToday)
        if let scheduleError { throw scheduleError }
    }

    func cancelReminder() {
        cancelCount += 1
    }
}

/// Preferências em memória, no lugar do `UserDefaults`.
@MainActor
final class PreferencesWorkerMock: PreferencesWorkerProtocol {
    var notificationsEnabled = false
}

private enum ReminderTestError: Error {
    case failed
}

// MARK: - Tests

@MainActor
@Suite("Tests for ReminderSchedulerService")
struct ReminderSchedulerServiceTests {

    // MARK: - Auxiliadores

    let modelContainer: ModelContainer = {
        let schema = Schema([Activity.self, ActivityResult.self, Profile.self])
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        return try! ModelContainer(for: schema, configurations: config)
    }()

    private struct SUT {
        let service: ReminderSchedulerService
        let preferences: PreferencesWorkerMock
        let notifications: NotificationWorkerMock
        let activityRepository: GenericRepository<Activity>
    }

    private func makeSUT() -> SUT {
        let preferences = PreferencesWorkerMock()
        let notifications = NotificationWorkerMock()
        let activityRepository = GenericRepository<Activity>(context: modelContainer.mainContext)
        let service = ReminderSchedulerService(preferences: preferences,
                                               activityRepository: activityRepository,
                                               notifications: notifications)
        return SUT(service: service, preferences: preferences,
                   notifications: notifications, activityRepository: activityRepository)
    }

    private func addCompletedActivity(to sut: SUT, daysAgo: Int = 0) throws {
        let date = try #require(Calendar.current.date(byAdding: .day, value: -daysAgo, to: Date()))
        try sut.activityRepository.add(Activity(category: .physical,
                                                result: ActivityResult(time: 60, humor: .pleasant),
                                                createdAt: date, name: "Concluída", description: "", archived: false))
    }

    // MARK: - isEnabled

    @Test(arguments: [true, false])
    func testingIsEnabledReflectsThePreference(isOn: Bool) {
        let sut = makeSUT()
        sut.preferences.notificationsEnabled = isOn

        #expect(sut.service.isEnabled == isOn)
    }

    // MARK: - refresh

    // Toggle desligado: não pode existir lembrete.
    @Test func testingRefreshWithToggleOffCancelsAndDoesNotSchedule() async {
        let sut = makeSUT()
        sut.preferences.notificationsEnabled = false

        await sut.service.refresh()

        #expect(sut.notifications.cancelCount == 1)
        #expect(sut.notifications.scheduleCalls.isEmpty)
    }

    // Ligado e ainda sem atividade hoje: o lembrete vale para hoje.
    @Test func testingRefreshWithoutActivityTodaySchedulesForToday() async {
        let sut = makeSUT()
        sut.preferences.notificationsEnabled = true

        await sut.service.refresh()

        #expect(sut.notifications.scheduleCalls == [false])
        #expect(sut.notifications.cancelCount == 0)
    }

    // Já fez um desafio hoje: o primeiro lembrete só vem amanhã.
    @Test func testingRefreshWithCompletedActivityTodaySkipsToday() async throws {
        let sut = makeSUT()
        sut.preferences.notificationsEnabled = true
        try addCompletedActivity(to: sut)

        await sut.service.refresh()

        #expect(sut.notifications.scheduleCalls == [true])
    }

    // Só ontem não conta: hoje ainda falta o desafio.
    @Test func testingRefreshIgnoresActivitiesFromOtherDays() async throws {
        let sut = makeSUT()
        sut.preferences.notificationsEnabled = true
        try addCompletedActivity(to: sut, daysAgo: 1)

        await sut.service.refresh()

        #expect(sut.notifications.scheduleCalls == [false])
    }

    // Sem resultado (ex.: desafio arquivado) não é desafio concluído.
    @Test func testingRefreshIgnoresActivitiesWithoutResult() async throws {
        let sut = makeSUT()
        sut.preferences.notificationsEnabled = true
        try sut.activityRepository.add(Activity(category: .cognitive, result: nil,
                                                createdAt: Date(), name: "Arquivada", description: "", archived: true))

        await sut.service.refresh()

        #expect(sut.notifications.scheduleCalls == [false])
    }

    // Chamar várias vezes deixa sempre o mesmo estado: é o que permite os Interactors só "avisarem".
    @Test func testingRefreshIsIdempotent() async throws {
        let sut = makeSUT()
        sut.preferences.notificationsEnabled = true
        try addCompletedActivity(to: sut)

        await sut.service.refresh()
        await sut.service.refresh()

        #expect(sut.notifications.scheduleCalls == [true, true])
    }

    // Falha ao agendar não derruba nada nem muda a preferência.
    @Test func testingRefreshSwallowsScheduleErrors() async {
        let sut = makeSUT()
        sut.preferences.notificationsEnabled = true
        sut.notifications.scheduleError = ReminderTestError.failed

        await sut.service.refresh()

        #expect(sut.notifications.scheduleCalls == [false])
        #expect(sut.preferences.notificationsEnabled == true)
    }

    // MARK: - setEnabled

    @Test func testingSetEnabledOnGrantedSavesPreferenceAndSchedules() async throws {
        let sut = makeSUT()

        let enabled = try await sut.service.setEnabled(true)

        #expect(enabled == true)
        #expect(sut.notifications.requestCount == 1)
        #expect(sut.preferences.notificationsEnabled == true)
        #expect(sut.notifications.scheduleCalls == [false])
    }

    // Permissão negada: a preferência fica desligada e nenhum lembrete é agendado.
    @Test func testingSetEnabledOnDeniedKeepsPreferenceOffAndDoesNotSchedule() async throws {
        let sut = makeSUT()
        sut.notifications.granted = false

        let enabled = try await sut.service.setEnabled(true)

        #expect(enabled == false)
        #expect(sut.preferences.notificationsEnabled == false)
        #expect(sut.notifications.scheduleCalls.isEmpty)
        #expect(sut.notifications.cancelCount == 1)
    }

    // Ligar depois de já ter feito o desafio do dia: o lembrete já nasce para amanhã.
    @Test func testingSetEnabledOnAfterCompletedActivitySkipsToday() async throws {
        let sut = makeSUT()
        try addCompletedActivity(to: sut)

        _ = try await sut.service.setEnabled(true)

        #expect(sut.notifications.scheduleCalls == [true])
    }

    // Desligar não pede permissão e cancela o lembrete pendente.
    @Test func testingSetEnabledOffDoesNotRequestPermissionAndCancels() async throws {
        let sut = makeSUT()
        sut.preferences.notificationsEnabled = true

        let enabled = try await sut.service.setEnabled(false)

        #expect(enabled == false)
        #expect(sut.notifications.requestCount == 0)
        #expect(sut.preferences.notificationsEnabled == false)
        #expect(sut.notifications.cancelCount == 1)
        #expect(sut.notifications.scheduleCalls.isEmpty)
    }

    // Erro ao pedir a permissão: sobe para o Interactor e nada é gravado nem agendado.
    @Test func testingSetEnabledPropagatesPermissionErrorWithoutChangingState() async {
        let sut = makeSUT()
        sut.notifications.requestError = ReminderTestError.failed

        await #expect(throws: ReminderTestError.self) {
            _ = try await sut.service.setEnabled(true)
        }

        #expect(sut.preferences.notificationsEnabled == false)
        #expect(sut.notifications.scheduleCalls.isEmpty)
    }
}
