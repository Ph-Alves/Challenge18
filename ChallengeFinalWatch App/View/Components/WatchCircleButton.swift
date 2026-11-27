//
//  WatchCircleButton.swift
//  ChallengeFinalWatch Watch App
//
//  Created by Paulo Henrique Costa Alves on 19/11/26.
//

import SwiftUI

/// Botão circular com um ícone (pausar e parar o cronômetro).
struct WatchCircleButton: View {

    /// SF Symbol do ícone.
    let systemImage: String
    var style: WatchButtonStyle = .primary
    var size: CGFloat = 58
    let accessibilityLabel: String
    let action: () -> Void

    private var backgroundColor: Color {
        switch style {
        case .primary: Color(white: 0.92)
        case .secondary: Color(white: 0.2)
        }
    }

    private var foregroundColor: Color {
        switch style {
        case .primary: .black
        case .secondary: .white
        }
    }

    var body: some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.title3)
                .foregroundStyle(foregroundColor)
                .frame(width: size, height: size)
                .background(backgroundColor, in: Circle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(accessibilityLabel)
    }
}

#Preview {
    HStack {
        WatchCircleButton(systemImage: "pause.fill", style: .secondary, accessibilityLabel: "pausar", action: {})
        WatchCircleButton(systemImage: "stop.fill", style: .primary, accessibilityLabel: "parar", action: {})
    }
}
