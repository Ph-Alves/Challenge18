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
    let onPause: () -> Void
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
                WatchCircleButton(systemImage: "pause.fill", style: .secondary, accessibilityLabel: "pausar", action: onPause)
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
        InProgressWatch(timeText: "00:00:00", onPause: {}, onStop: {}, onClose: {})
    }
}
