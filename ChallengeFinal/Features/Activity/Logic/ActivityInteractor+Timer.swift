//
//  ActivityInteractor+Timer.swift
//  ChallengeFinal
//
//  Created by Débora Cristina Silva Ferreira on 26/10/26.
//

import Foundation

// MARK: - Step .inProgress (cronômetro)

/// Ações do cronômetro da atividade em andamento.
///
/// O tempo NÃO é um contador (`segundos += 1`): guarda só a data de início
/// (`timerStartDate`) e calcula "agora - início" quando precisa. Assim o
/// valor continua certo mesmo se o app for para o background.
/// O `TimerWorker` só entrega os "ticks" (um por segundo) que mandam a tela
/// atualizar; ele não conta nada.
extension ActivityInteractor {

    /// Começa a contar: guarda a data de início e, a cada tick, manda o tempo
    /// atual para o Presenter (que formata e entrega à Store).
    func startTimer( ) {
        // Garante um só Task rodando, caso o início seja chamado duas vezes.
        timerTask?.cancel()
        let startDate = Date()
        timerStartDate = startDate
        
        // Liga a Live Activity (Dynamic Island) com a MESMA data do cronômetro do app e o grupo
        // da atividade (`category.text`). O `Task` é necessário porque o worker é `async`.
        Task { await liveActivity.startLiveActivity(name: category.text, startDate: startDate) }
        
        // O Task é necessário porque o `for await` só roda em contexto assíncrono.
        // Fica guardado em `timerTask` para podermos cancelar depois.
        // `[weak self]` evita que o Task segure o Interactor vivo para sempre.
        timerTask = Task { [weak self] in
            guard let ticks = self?.timer.ticks() else { return }

            // Espera cada tick do worker (1 por segundo) e só então atualiza a tela.
            for await _ in ticks {
                guard let self else { return }
                presenter.presentTime(currentElapsed())
            }
        }
    }

    /// Terminou a atividade: para os ticks e fixa o tempo final em `timerElapsed`,
    /// que vai para o `ActivityResult` no final do fluxo.
    func stopTimer() {
        timerTask?.cancel()
        timerElapsed = currentElapsed()
        timerStartDate = nil
        
        // A ilha passa a mostrar o tempo final (parado) e some depois de alguns segundos.
        Task { await liveActivity.stopLiveActivity(elapsed: timerElapsed)}
    }

    /// Cancelou a atividade: para os ticks e descarta o tempo (nada é salvo).
    /// A tela volta a "00:00:00".
    func cancelTimer() {
        timerTask?.cancel()
        timerTask = nil
        timerStartDate = nil
        timerElapsed = 0
        presenter.presentTime(0)
        
        // Encerra a ilha na hora, sem mostrar o tempo (nada foi concluído).
        Task { await liveActivity.cancelLiveActivity()}
    }

    /// Quanto tempo já passou desde `timerStartDate`, em segundos.
    /// Devolve `0` se o cronômetro não estiver rodando.
    func currentElapsed() -> TimeInterval {
        guard let start = timerStartDate else { return 0}
        return Date().timeIntervalSince(start)
    }
}
