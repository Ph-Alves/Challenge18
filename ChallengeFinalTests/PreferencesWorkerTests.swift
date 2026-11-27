//
//  PreferencesWorkerTests.swift
//  ChallengeFinalTests
//
//  Created by Débora Cristina Silva Ferreira on 27/11/26.
//

import Foundation
import Testing
@testable import ChallengeFinal

/// Testa o `PreferencesWorker` real, sempre com um `UserDefaults` só do teste
/// (para não mexer no do app nem em outros testes).
@MainActor
@Suite("Tests for PreferencesWorker")
struct PreferencesWorkerTests {

    /// `UserDefaults` isolado. Quem chama apaga o domínio no fim com `removeDomain`.
    private func makeIsolatedDefaults() -> (defaults: UserDefaults, name: String) {
        let name = "PreferencesWorkerTests.\(UUID().uuidString)"
        return (UserDefaults(suiteName: name)!, name)
    }

    // MARK: - notificationsEnabled

    // Quem nunca mexeu no toggle começa com as notificações desligadas.
    @Test func testingNotificationsStartDisabled() {
        let (defaults, name) = makeIsolatedDefaults()
        defer { defaults.removePersistentDomain(forName: name) }

        let worker = PreferencesWorker(defaults: defaults)

        #expect(worker.notificationsEnabled == false)
    }

    @Test(arguments: [true, false])
    func testingNotificationsPersistTheValue(isOn: Bool) {
        let (defaults, name) = makeIsolatedDefaults()
        defer { defaults.removePersistentDomain(forName: name) }
        let worker = PreferencesWorker(defaults: defaults)

        worker.notificationsEnabled = isOn

        #expect(worker.notificationsEnabled == isOn)
    }

    // O valor mora no `UserDefaults`, não no worker: outra instância enxerga o mesmo valor.
    @Test func testingNotificationsSurviveANewWorkerInstance() {
        let (defaults, name) = makeIsolatedDefaults()
        defer { defaults.removePersistentDomain(forName: name) }
        PreferencesWorker(defaults: defaults).notificationsEnabled = true

        let another = PreferencesWorker(defaults: defaults)

        #expect(another.notificationsEnabled == true)
    }

    @Test func testingNotificationsCanBeTurnedBackOff() {
        let (defaults, name) = makeIsolatedDefaults()
        defer { defaults.removePersistentDomain(forName: name) }
        let worker = PreferencesWorker(defaults: defaults)
        worker.notificationsEnabled = true

        worker.notificationsEnabled = false

        #expect(worker.notificationsEnabled == false)
    }

    // Trocar essa chave sem querer faria o toggle de todo mundo voltar a "desligado" depois da atualização.
    @Test func testingNotificationsUseTheStableKey() {
        let (defaults, name) = makeIsolatedDefaults()
        defer { defaults.removePersistentDomain(forName: name) }
        let worker = PreferencesWorker(defaults: defaults)

        worker.notificationsEnabled = true

        #expect(defaults.bool(forKey: "preferences.notifications") == true)
    }
}
