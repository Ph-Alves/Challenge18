//
//  PhotoCard.swift
//  ChallengeFinal
//
//  Created by Raquel Souza on 26/10/26.
//

import SwiftUI

/// Card de foto reutilizável.
///
/// - Sem foto: mostra o fundo pontilhado com borda preta.
/// - Com foto: mostra a imagem preenchendo o card, sem borda.

///
/// Uso simples (só exibir uma foto, ex.: no resumo ou no histórico):
/// ```swift
/// PhotoCard(photo: image)
/// ```

struct PhotoCard: View {
    @Environment(DesignSystem.self) private var designSystem

    /// Foto a mostrar. `nil` = estado vazio (pontilhado).
    let photo: Image?

    /// Altura do card. A largura ocupa todo o espaço disponível.
    var height: CGFloat = 150

    /// Arredondamento dos cantos.
    var cornerRadius: CGFloat = 26

    var body: some View {
        content
            .frame(maxWidth: .infinity)
            .frame(height: height)
            .clipShape(.rect(cornerRadius: cornerRadius))
            
    }

    @ViewBuilder
    private var content: some View {
        if let photo {
            photo
                .resizable()
                .scaledToFill()
        } else {
            Image(designSystem.style.icons.photoPlaceholder)
                .resizable()
                .scaledToFit()
        }
    }
}

// MARK: - Previews

#Preview("Vazio") {
    PhotoCard(photo: nil)
    .padding(48)
    .environment(DesignSystem.shared)
}

#Preview("Com foto") {
    PhotoCard(photo: Image(systemName: "person.crop.square.fill")).environment(DesignSystem.shared)
    .padding(48)
    .environment(DesignSystem.shared)
}

#Preview("Só exibição, menor") {
    PhotoCard(
        photo: Image(systemName: "person.crop.square.fill"),
        height: 160,
        cornerRadius: 20
    )
    .padding(48)
    .environment(DesignSystem.shared)
}
