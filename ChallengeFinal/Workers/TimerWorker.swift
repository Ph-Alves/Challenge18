//
//  TimerWorker.swift
//  ChallengeFinal
//
//  Created by Débora Cristina Silva Ferreira on 26/10/26.
//

import Foundation
// MARK: - TimerWorkerProtocol
protocol TimerWorkerProtocol{
    /// Retorna um fluxo de sinais emitidos a cada segundo.
    /// AsyncStream permite produzir uma sequencia dw valores que podem ser consumidos de maneira assincrona
    func ticks( ) -> AsyncStream<Void>
}


// MARK: - TimerWorker
struct TimerWorker: TimerWorkerProtocol {
    
    /// AsyncStream é uma fila de valores que chegam com o tempo. O Void significa que cada item não carrega dado, é só um aviso.
    func ticks() -> AsyncStream<Void> {
        /// O continuation é o por onde a ocorre a comunicacao com quem esta ouvindo o worker. O continuation permite que controle a produção dos elementos do fluxo.
        AsyncStream { continuation in
            /// Task { } cria um trabalho assíncrono em paralelo. Ele é necessário porque o Task.sleep é async, e o bloco do AsyncStream não é.
            let task = Task {
                /// Repete enquanto ninguem cancelar a execucao do worker
                while !Task.isCancelled {
                    /// espera 1 segundo sem travar a tela.
                    do { try await Task.sleep(for: .seconds(1)) } catch {break}
                    /// manda um tick para quem está ouvindo.
                    continuation.yield()
                }
                continuation.finish()
            }
            /// avisa que o stream acabou.

            continuation.onTermination = { _ in task.cancel()}
        }
    }
    
    
}
