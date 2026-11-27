//
//  ReminderSchedulerService.swift
//  ChallengeFinal
//
//  Created by Débora Cristina Silva Ferreira on 27/11/26.
//

import Foundation
import SwiftData

/// A única porta de entrada para tudo que é "lembrete diário" no app.
///
/// Os Interactors e o `RootView` não conhecem `UserDefaults`, permissão nem agendamento:
/// só pedem `setEnabled` (toggle) ou `refresh` ("algo mudou, confira o lembrete").
protocol ReminderSchedulerServiceProtocol {
    /// `true` se o usuário deixou o lembrete ligado (e a permissão foi concedida).
    var isEnabled: Bool { get }
    /// Deixa o lembrete no estado certo, de acordo com o toggle e com as atividades de hoje.
    func refresh() async
    /// Liga ou desliga o lembrete. Devolve `false` se o usuário negou a permissão.
    func setEnabled(_ isOn: Bool) async throws -> Bool
}

/// Decide se o lembrete diário deve existir e manda o `NotificationWorker` agendar ou cancelar.
///
/// REGRA DO APP: o lembrete das 18h só vale para quem LIGOU o toggle e AINDA NÃO fez
/// nenhum desafio hoje. O iOS não deixa o app acordar às 18h para conferir isso, então a
/// regra é aplicada ANTES: agendamos uma janela de dias e, quando o usuário conclui uma
/// atividade, refazemos a janela sem o dia de hoje.
///
/// QUEM CHAMA E QUANDO
/// - `ProfileInteractor` → `setEnabled` (usuário mexeu no toggle) e `isEnabled` (mostrar o toggle).
/// - `ActivityInteractor` → `refresh` ao concluir uma atividade.
/// - `RootView` → `refresh` ao abrir o app e quando ele volta a ficar ativo.
///
/// Dependências (todas por protocolo/repositório, para testar sem tocar no sistema):
/// preferência do toggle, atividades salvas e o Worker de notificações.
struct ReminderSchedulerService: ReminderSchedulerServiceProtocol {
    let preferences: PreferencesWorkerProtocol
    let activityRepository: GenericRepository<Activity>
    let notifications: NotificationWorkerProtocol

    /// Estado do toggle, lido da preferência salva. Não consulta o iOS: se o usuário revogar
    /// a permissão nos Ajustes, o toggle continua `true` até a próxima vez que ele mexer.
    var isEnabled: Bool {
        preferences.notificationsEnabled
    }

    /// Liga ou desliga o lembrete (é o que o toggle das Configurações chama).
    ///
    /// COMPORTAMENTO
    /// - Ligar (`true`): pede a permissão ao iOS. A preferência passa a valer o que o
    ///   usuário respondeu: concedeu → `true`, negou → `false`.
    /// - Desligar (`false`): grava `false` sem pedir permissão nenhuma.
    /// - Nos dois casos chama `refresh()` em seguida. Como o `refresh()` lê a preferência
    ///   que acabou de ser gravada, ele agenda a janela (ligado) ou cancela tudo (desligado).
    ///   Negar a permissão também termina em cancelar, sem agendar nada.
    ///
    /// RETORNO E ERRO
    /// - Devolve o estado FINAL do toggle. Ligar e receber `false` significa "permissão
    ///   negada": o Interactor volta o toggle para desligado e mostra o alerta de Ajustes.
    /// - Se o pedido de permissão lançar erro, o erro sobe, a preferência NÃO muda e nada
    ///   é agendado.
    func setEnabled(_ isOn: Bool) async throws -> Bool {
        if isOn {
            let granted = try await notifications.requestAuthorization()
            preferences.notificationsEnabled = granted
        } else {
            preferences.notificationsEnabled = false
        }
        await refresh()
        return preferences.notificationsEnabled
    }
    
    /// Deixa o lembrete no estado certo. Chame sempre que algo que importa para ele mudar.
    ///
    /// É IDEMPOTENTE: chamar uma vez ou dez vezes seguidas deixa exatamente o mesmo
    /// resultado. Por isso quem chama não precisa saber se "já agendou antes".
    ///
    /// PASSOS
    /// 1. Toggle desligado → cancela todos os lembretes pendentes e termina.
    /// 2. Toggle ligado → confere se existe alguma atividade CONCLUÍDA hoje (com resultado,
    ///    criada hoje). Atividade arquivada ou sem resultado não conta, nem as de outros dias.
    /// 3. Refaz a janela de lembretes: se já fez algo hoje, o primeiro lembrete é amanhã;
    ///    se não, é hoje às 18h (ou amanhã, caso as 18h de hoje já tenham passado).
    ///
    /// ERROS
    /// - Não lança. Se a leitura das atividades falhar, trata como "não fez nada hoje"
    ///   (o mais seguro para um lembrete: melhor lembrar à toa do que não lembrar).
    /// - Se o agendamento falhar, o erro é ignorado e a próxima chamada tenta de novo.
    func refresh() async {
        // 1. Toggle desligado: não deve existir lembrete
        guard preferences.notificationsEnabled else {
            notifications.cancelReminder()
            return
        }

        // 2. Já fez atividade hoje?
        let activities = (try? activityRepository.getAll()) ?? []
        let doneToday = activities.contains {
            $0.result != nil && Calendar.current.isDateInToday($0.createdAt)
        }

        // 3. Agenda: para hoje às 18h, ou para amanhã se já fez
        try? await notifications.scheduleReminder(skipToday: doneToday)
    }
}

extension ReminderSchedulerService {
    /// Monta o Service de produção com os Workers reais e o `ModelContext` do app.
    /// Usado pelos Builders e pelo `RootView`, para a montagem ficar num lugar só.
    static func make(context: ModelContext) -> ReminderSchedulerService {
        ReminderSchedulerService(
            preferences: PreferencesWorker(),
            activityRepository: GenericRepository<Activity>(context: context),
            notifications: NotificationWorker()
        )
    }
}
