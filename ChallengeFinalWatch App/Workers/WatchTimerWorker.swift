//
//  WatchTimerWorker.swift
//  ChallengeFinalWatch Watch App
//
//  Created by Paulo Henrique Costa Alves on 23/11/26.
//

import Foundation

// MARK: - WatchTimerWorkerProtocol

/// O que o Interactor enxerga do cronômetro: só os "ticks" (um aviso por segundo).
///
/// O worker NÃO conta o tempo nem guarda estado. Quem sabe quanto tempo passou é o
/// Interactor, que calcula a partir da data de início. Com o protocolo, nos testes
/// dá para passar um worker falso que dispara os ticks na hora.
protocol WatchTimerWorkerProtocol {
    /// Fluxo de sinais emitidos a cada segundo.
    func ticks() -> AsyncStream<Void>
}

// MARK: - WatchTimerWorker

/// Gera um tick por segundo enquanto alguém estiver ouvindo.
/// Mesma ideia do `TimerWorker` do iOS: o cancelamento é automático, porque quando
/// quem consome cancela o `Task` dele o fluxo termina e o loop interno para junto.
struct WatchTimerWorker: WatchTimerWorkerProtocol {

    func ticks() -> AsyncStream<Void> {
        AsyncStream { continuation in
            let task = Task {
                while !Task.isCancelled {
                    // Se cancelar durante a espera, o `sleep` lança erro e sai sem mandar um tick a mais.
                    do { try await Task.sleep(for: .seconds(1)) } catch { break }
                    continuation.yield()
                }
                continuation.finish()
            }
            // Sem isso o `while` continuaria rodando mesmo sem ninguém ouvindo.
            continuation.onTermination = { _ in task.cancel() }
        }
    }
}
