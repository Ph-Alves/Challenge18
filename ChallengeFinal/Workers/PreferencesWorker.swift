//
//  PreferencesWorker.swift
//  ChallengeFinal
//
//  Created by Débora Cristina Silva Ferreira on 27/11/26.
//

import Foundation

/// Preferências do usuário guardadas no aparelho. Hoje só existe o toggle de notificações.
///
/// `AnyObject` porque quem usa (o `ReminderSchedulerService`, que é uma struct) precisa
/// GRAVAR a preferência sem que o `let` impeça a escrita.
protocol PreferencesWorkerProtocol: AnyObject {
    /// `true` se o usuário ligou o lembrete diário. Começa `false`.
    var notificationsEnabled: Bool { get set }
}

/// Guarda as preferências no `UserDefaults`. É a ÚNICA fonte da verdade do toggle de
/// notificações: o `Profile` não guarda mais isso.
final class PreferencesWorker: PreferencesWorkerProtocol {
    private enum Key {
        /// Não troque esta chave: mudar o texto faria o toggle de todo mundo voltar a
        /// "desligado" depois da atualização (o valor antigo ficaria guardado numa chave
        /// que ninguém mais lê). Há um teste que trava este valor.
        static let notifications = "preferences.notifications"
    }

    private let defaults: UserDefaults

    /// `defaults` é injetável para os testes usarem um `UserDefaults` isolado, sem mexer
    /// no do app. Em produção usa o `.standard`.
    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    /// Lê e grava na hora. Persiste entre aberturas do app. Quem nunca mexeu no toggle lê `false`.
    var notificationsEnabled: Bool {
        get { defaults.bool(forKey: Key.notifications) }
        set { defaults.set(newValue, forKey: Key.notifications) }
    }
}

