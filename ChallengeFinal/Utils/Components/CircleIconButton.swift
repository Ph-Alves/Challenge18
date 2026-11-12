//
//  CircleIconButton.swift
//  ChallengeFinal
//
//  Created by Raquel Souza on 03/11/26.
//

import SwiftUI

// MARK: - Botão circular cinza
// Usado no botão de arquivados (topo da lista) e no "devolver" de cada arquivado.
struct CircleIconButton: View {
    @Environment(DesignSystem.self) private var designSystem
    let icon: String
    var size: CGFloat = 40
    var padding: CGFloat = 10
    let action: () -> Void
    let background: Color

    var body: some View {
        Button(action: action) {
            Image(icon)
                .resizable()
                .frame(width: size, height: size)
                .padding(padding)
        }
        .buttonStyle(.plain)
        .background(background)
        .clipShape(Circle())

    }
}
