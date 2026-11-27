//
//  NotificationWorker.swift
//  ChallengeFinal
//
//  Created by Raquel Souza on 16/10/26.
//

import UserNotifications

/// O que o resto do app enxerga do Worker de notificações.
///
/// O Worker só EXECUTA no sistema (pedir permissão, agendar, cancelar). Ele não decide
/// nada: quem decide se o lembrete deve existir hoje é o `ReminderSchedulerService`.
protocol NotificationWorkerProtocol {
    /// Pede ao usuário a permissão para mostrar notificações. Devolve `true` se foi concedida.
    func requestAuthorization() async throws -> Bool
    /// Refaz a janela de lembretes diários. `skipToday` pula o lembrete de hoje.
    func scheduleReminder(skipToday: Bool) async throws
    /// Remove todos os lembretes que ainda não foram entregues.
    func cancelReminder()
}

/// Fala com o `UNUserNotificationCenter` para agendar o lembrete diário das 18h
/// ("Ainda dá tempo de se desafiar!").
///
/// COMO FUNCIONA O AGENDAMENTO
/// - Uma notificação local é entregue pelo SISTEMA, no horário marcado, mesmo com o app
///   fechado. O app NÃO roda código quando ela toca, então não dá para "reagendar a de
///   amanhã" no momento em que ela chega.
/// - Por isso agendamos uma JANELA de vários dias de uma vez (um lembrete por dia, cada um com o seu identificador). Quem renova a janela é o `ReminderSchedulerService`,
///   chamando `scheduleReminder` quando o usuário liga o toggle, conclui uma atividade ou
///   abre o app.
/// - Se o usuário ficar mais de `daysAhead` dias sem abrir o app, os lembretes acabam sozinhos.
struct NotificationWorker: NotificationWorkerProtocol {
    private let center = UNUserNotificationCenter.current()

    /// Começo do identificador de cada lembrete (`daily-reminder-2026-11-27`).
    /// O sufixo é a data, então cada dia tem o seu e dá para remover/substituir um por um.
    private let reminderPrefix = "daily-reminder-"
    /// Tamanho da janela, em dias de calendário contando HOJE (hoje + 29 dias à frente).
    /// O iOS guarda no máximo 64 notificações pendentes por app, então 30 cabe com folga.
    private let daysAhead = 30
    /// Hora do lembrete, no fuso do aparelho (18h). O minuto é sempre 0.
    private let reminderHour = 18

    /// Pede a permissão de notificação (alerta, som e badge).
    ///
    /// - O iOS só mostra o diálogo UMA vez na vida do app. Nas chamadas seguintes ele devolve
    ///   a resposta já dada, sem mostrar nada. Quem negou precisa liberar em Ajustes.
    /// - Devolve `true` se concedida e `false` se negada (negar NÃO é erro).
    /// - Só lança erro se o sistema falhar ao processar o pedido (`UNError`).
    /// - Não agenda nada: só pergunta. O agendamento vem depois, no `scheduleReminder`.
    func requestAuthorization() async throws -> Bool {
        try await center.requestAuthorization(options: [.alert, .sound, .badge])
    }

    /// Agenda a janela de lembretes dos próximos `daysAhead` dias, todos às `reminderHour`.
    ///
    /// COMPORTAMENTO
    /// 1. Começa apagando a janela anterior (`cancelReminder`). Assim chamar de novo nunca
    ///    duplica lembretes: sempre sobra só a janela nova.
    /// 2. Percorre os dias a partir de HOJE (`offset` 0 = hoje, 1 = amanhã...).
    /// 3. Pula o dia de hoje em dois casos:
    ///    - `skipToday == true`: o usuário já fez o desafio de hoje;
    ///    - o horário de hoje já passou (`target > .now` falha): não se agenda no passado.
    ///    Por isso a janela tem 30 lembretes antes do horário e 29 depois dele.
    /// 4. Cada dia vira um `UNCalendarNotificationTrigger` com `repeats: false`. Ele compara
    ///    ano, mês, dia, hora e minuto (os segundos são descartados), então toca no começo
    ///    do minuto marcado. Não repete porque uma repetição diária não deixaria pular só hoje.
    /// 5. O identificador inclui a data: adicionar um lembrete de uma data que já existe o
    ///    SUBSTITUI em vez de duplicar.
    ///
    /// ATENÇÕES
    /// - Não verifica a permissão: sem permissão o `add` funciona, mas o iOS nunca entrega.
    ///   Quem cuida disso é o Service, que só agenda se o toggle estiver ligado (e ele só
    ///   fica ligado se a permissão foi concedida).
    /// - Se o `add` falhar no meio, o erro sobe e os dias anteriores já ficam agendados
    ///   (janela parcial). A próxima chamada refaz tudo do zero.
    /// - O valor padrão `skipToday = false` vale só ao chamar direto no tipo concreto: o
    ///   protocolo exige o parâmetro.
    func scheduleReminder(skipToday: Bool = false) async throws {
        cancelReminder()

        let calendar = Calendar.current
        let content = makeContent()

        for offset in 0..<daysAhead {
            if offset == 0 && skipToday { continue }

            guard let day = calendar.date(byAdding: .day, value: offset, to: .now),
                  let target = calendar.date(bySettingHour: reminderHour, minute: 0, second: 0, of: day),
                  target > .now else { continue }
            let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: target)
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
            let request = UNNotificationRequest(identifier: identifier(for: day), content: content, trigger: trigger)

            try await center.add(request)

        }
    }

    /// Remove os lembretes PENDENTES (ainda não entregues) dos próximos `daysAhead` dias.
    ///
    /// - Síncrona e sem erro: se não houver nada para remover, não faz nada.
    /// - Só mexe nos pendentes. Uma notificação que já chegou e está na central de
    ///   notificações do aparelho continua lá.
    /// - Também remove o identificador antigo `daily-reminder`, de quando existia um único
    ///   lembrete, para quem atualizou o app não ficar com um lembrete órfão.
    /// - É chamada pelo `scheduleReminder` (para limpar a janela antiga) e pelo Service
    ///   quando o toggle é desligado.
    func cancelReminder() {
        let calendar = Calendar.current
        var ids = (0..<daysAhead).compactMap { offset in
            calendar.date(byAdding: .day, value: offset, to: .now).map(identifier(for:))
        }
        ids.append("daily-reminder")
        center.removePendingNotificationRequests(withIdentifiers: ids)
    }

    // MARK: - Auxiliares

    /// Texto e som do lembrete. O mesmo conteúdo serve para todos os dias da janela.
    private func makeContent() -> UNMutableNotificationContent {
        let content = UNMutableNotificationContent()
        content.title = "Ainda dá tempo de se desafiar!"
        content.body = "Que tal sair do piloto automático e fazer algo por você?"
        content.sound = .default
        return content
    }

    /// Um id por data (ex.: `daily-reminder-2026-11-27`), para cada dia ter o seu lembrete.
    private func identifier(for day: Date) -> String {
        let c = Calendar.current.dateComponents([.year, .month, .day], from: day)
        return String(format: "%@%04d-%02d-%02d", reminderPrefix, c.year ?? 0, c.month ?? 0, c.day ?? 0)
    }
}
