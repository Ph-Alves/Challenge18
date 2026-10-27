//
//  WidgetWorker.swift
//  ChallengeFinal
//
//  Created by Raquel Souza on 16/10/26.
//

import Foundation
import ActivityKit

// MARK: - WidgetWorkerProtocol

/// O que o Interactor enxerga da Live Activity (Dynamic Island): iniciar, parar e cancelar.
///
/// Com o protocolo, nos testes dá para passar um worker falso que só anota as chamadas,
/// sem abrir uma ilha de verdade. As funções são `async` porque o ActivityKit é assíncrono.
protocol WidgetWorkerProtocol {
    func startLiveActivity(name: String, startDate: Date) async
    func stopLiveActivity(elapsed: TimeInterval) async
    func cancelLiveActivity() async
    
}

// MARK: - WidgetWorker

/// Liga e desliga a Live Activity do cronômetro.
///
/// É `class` (e não `struct`, como o `TimerWorker`) porque precisa GUARDAR a referência da
/// atividade criada em `startLiveActivity` para conseguir encerrá-la depois.
/// Não conhece o app: recebe só o texto (`name`) e as datas, tudo já calculado pelo Interactor.
final class WidgetWorker: WidgetWorkerProtocol {
    /// `ActivityKit.Activity` com o módulo na frente porque o app tem um modelo
    /// chamado `Activity` (SwiftData) que, sem isso, esconde o do ActivityKit.
    private var activity: ActivityKit.Activity<ChallengeFinalWidgetAttributes>?

    
    /// Abre a ilha. `name` é o grupo da atividade e `startDate` é a MESMA data do cronômetro
    /// do app, para os dois mostrarem o mesmo tempo. Se der erro (por exemplo, o usuário
    /// desligou as Live Activities nos Ajustes), só registra no console: o cronômetro do app segue.
    func startLiveActivity(name: String, startDate: Date) async {
        // Garante uma só ilha por vez, caso o início seja chamado duas vezes.
        await cancelLiveActivity()

        let attributes = ChallengeFinalWidgetAttributes (
            name: name
        )
        
        let state = ChallengeFinalWidgetAttributes.ContentState(
            emoji: "timer.circle",
            startTime: startDate,
            isRunning: true,
            elapsedSeconds: 0
        )
        
        do {
            activity = try ActivityKit.Activity.request(
                attributes: attributes,
                content: ActivityContent(
                    state: state,
                    staleDate: nil
                )
            )
            
            print("Live Activity iniciada: \(activity?.id ?? "")")
        } catch {
            print("ERRO: \(error)")
        }
    }
    
    /// Terminou a atividade: atualiza a ilha para "parado" com o tempo final (`elapsed`)
    /// e a encerra depois de alguns segundos, para a pessoa conseguir ler o resultado.
    func stopLiveActivity(elapsed: TimeInterval) async {
        guard let activity else { return }
        
        let finalState = ChallengeFinalWidgetAttributes.ContentState(
            emoji: "timer.circle",
            startTime: activity.content.state.startTime,
            isRunning: false,
            elapsedSeconds: Int(elapsed)
        )
     
        
        await activity.end(
            ActivityContent(state: finalState, staleDate: nil),
            // a ilha continua 5 segundos mostrando o tempo final antes de sumir
            dismissalPolicy: .after(Date().addingTimeInterval(5))
        )
        self.activity = nil
    }
    
    /// Cancelou ou saiu do fluxo: encerra na hora, sem mostrar o tempo.
    /// Percorre TODAS as ilhas do app (e não só a guardada em `activity`), para não sobrar
    /// nenhuma "órfã" de uma execução anterior.
    func cancelLiveActivity() async {
        for running in ActivityKit.Activity<ChallengeFinalWidgetAttributes>.activities {
            await running.end(nil, dismissalPolicy: .immediate)
        }
        activity = nil
    }
    

    
}
