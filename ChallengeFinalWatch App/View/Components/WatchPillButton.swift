//
//  WatchPillButton.swift
//  ChallengeFinalWatch Watch App
//
//  Created by Paulo Henrique Costa Alves on 19/11/26.
//

import SwiftUI

enum WatchButtonStyle {
    /// Fundo claro, texto escuro ("aceitar", "home").
    case primary
    /// Fundo escuro, texto claro ("outro desafio").
    case secondary
}

/// Botão em pílula que ocupa a largura toda.
struct WatchPillButton: View {

    let title: String
    var style: WatchButtonStyle = .primary
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
            Text(title)
                .font(.headline)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .foregroundStyle(foregroundColor)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14.5)
                .background(backgroundColor, in: Capsule())
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    VStack {
        WatchPillButton(title: "aceitar", style: .primary, action: {})
        WatchPillButton(title: "outro desafio", style: .secondary, action: {})
    }
    .padding()
}
