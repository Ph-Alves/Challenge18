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
    let icon: String
    var size: CGFloat = 44
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: size * 0.4, weight: .semibold))
                .foregroundStyle(.black)
                .frame(width: size, height: size)
                .background(Circle().fill(Color.E_0_E_0_E_0))
                .contentShape(Circle())
        }
        .buttonStyle(.plain)
    }
}
