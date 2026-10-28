//
//  ChallengeFinalWidgetAttributes.swift
//  ChallengeFinal
//
//  Created by Débora Cristina Silva Ferreira on 27/10/26.
//

import Foundation
import ActivityKit

/// Os dados da Live Activity do cronômetro.
///
/// O ActivityKit separa o que é FIXO (`ChallengeFinalWidgetAttributes`, definido ao iniciar)
/// do que MUDA (`ContentState`, atualizado depois). O app e a widget extension precisam
/// enxergar este mesmo tipo, por isso o arquivo está nos dois alvos (Target Membership).
///
/// `nonisolated` porque o app roda tudo na main thread por padrão (`@MainActor`), e o
/// ActivityKit usa estes tipos fora dela; sem isso o compilador avisa (erro no Swift 6).
nonisolated struct ChallengeFinalWidgetAttributes: ActivityAttributes {
        // Dados que podem mudar enquanto a live activity ta ativa
        nonisolated struct ContentState: Codable, Hashable {
            // emoji que pode ser exibido na interface.
            var emoji: String
            // data e a hora de início do cronômetro. A ilha conta a partir dela, sozinha,
            // com `Text(startTime, style: .timer)`: o app não precisa atualizar a cada segundo.
            var startTime: Date
            // Indica se o cronômetro está rodando.
            var isRunning: Bool
            // tempo transcorrido em segundos. Só vale quando `isRunning` é falso (tempo final).
            var elapsedSeconds: Int
        }
        
        // Não muda durante a atividade: o grupo da atividade (mente, movimento, sentidos, conexão).
        // Aparece na ilha como `context.attributes.name`.
        var name: String
    
}
