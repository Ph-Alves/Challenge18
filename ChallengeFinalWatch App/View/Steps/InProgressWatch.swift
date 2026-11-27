//
//  InProgressWatch.swift
//  ChallengeFinalWatch Watch App
//
//  Created by Paulo Henrique Costa Alves on 19/11/26.
//

import SwiftUI

/// Step `.inProgress`: o cronômetro com os botões de pausar e parar.
struct InProgressWatch: View {

    /// Tempo já formatado ("hh:mm:ss").
    let timeText: String
    /// Pausado: o botão da esquerda mostra "tocar" em vez de "pausar".
    let isPaused: Bool
    /// Botão da esquerda: alterna entre pausar e retomar.
    let onTogglePause: () -> Void
    /// Botão da direita: para o cronômetro e segue para o "arrasou".
    let onStop: () -> Void
    let onClose: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            Text(timeText)
                .font(.system(.title, weight: .bold))
                .monospacedDigit()
                .minimumScaleFactor(0.7)
                .lineLimit(1)

            HStack(spacing: 26) {
                WatchCircleButton(
                    systemImage: isPaused ? "play.fill" : "pause.fill",
                    style: .secondary,
                    accessibilityLabel: isPaused ? "retomar" : "pausar",
                    action: onTogglePause
                )
                WatchCircleButton(systemImage: "stop.fill", style: .primary, accessibilityLabel: "parar", action: onStop)
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(role: .close, action: onClose)
            }
        }
    }
}

#Preview {
    NavigationStack {
        InProgressWatch(timeText: "00:00:00", isPaused: false, onTogglePause: {}, onStop: {}, onClose: {})
    }
}
