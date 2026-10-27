//
//  TimerWorker.swift
//  ChallengeFinal
//
//  Created by Débora Cristina Silva Ferreira on 26/10/26.
//

import Foundation
// MARK: - TimerWorkerProtocol

/// O que o Interactor enxerga do cronômetro: só os "ticks" (um aviso por segundo).
///
/// O worker NÃO conta o tempo nem guarda estado. Quem sabe quanto tempo passou é o
/// Interactor, que calcula a partir da data de início (`timerStartDate`).
/// Com o protocolo, nos testes dá para passar um worker falso que dispara os
/// ticks na hora, sem esperar 1 segundo de verdade.
protocol TimerWorkerProtocol{
    /// Retorna um fluxo de sinais emitidos a cada segundo.
    /// AsyncStream permite produzir uma sequência de valores que podem ser consumidos de maneira assíncrona
    func ticks( ) -> AsyncStream<Void>
}


// MARK: - TimerWorker

/// Gera um tick por segundo enquanto alguém estiver ouvindo.
///
/// É `struct` porque não guarda nada (sem estado): cada chamada de `ticks()` cria o
/// seu próprio fluxo. O cancelamento é automático: quando quem consome cancela o
/// `Task` dele, o fluxo termina e o loop interno para junto.
struct TimerWorker: TimerWorkerProtocol {

    /// AsyncStream é uma fila de valores que chegam com o tempo. O Void significa que cada item não carrega dado, é só um aviso.
    func ticks() -> AsyncStream<Void> {
        /// O continuation é o "canal" por onde o worker se comunica com quem está ouvindo:
        /// `yield()` manda um valor e `finish()` avisa que o fluxo acabou.
        AsyncStream { continuation in
            /// Task { } cria um trabalho assíncrono em paralelo. Ele é necessário porque o Task.sleep é async, e o bloco do AsyncStream não é.
            let task = Task {
                /// Repete enquanto ninguem cancelar a execucao do worker
                while !Task.isCancelled {
                    /// espera 1 segundo sem travar a tela. Se for cancelado durante a espera,
                    /// o `sleep` lança erro e o `break` sai do loop sem mandar um tick a mais.
                    do { try await Task.sleep(for: .seconds(1)) } catch {break}
                    /// manda um tick para quem está ouvindo.
                    continuation.yield()
                }
                /// Saiu do loop (foi cancelado): avisa que o stream acabou.
                continuation.finish()
            }
            /// Quando quem escuta para (o consumidor cancelou o Task dele), cancela o loop acima.
            /// Sem isso o `while` continuaria rodando mesmo sem ninguém ouvindo.

            continuation.onTermination = { _ in task.cancel()}
        }
    }


}
