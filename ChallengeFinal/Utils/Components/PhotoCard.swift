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
/// - Botão (opcional): fica "encaixado" na borda de baixo do card.
///
/// Uso simples (só exibir uma foto, ex.: no resumo ou no histórico):
/// ```swift
/// PhotoCard(photo: image)
/// ```

struct PhotoCard: View {

    /// Foto a mostrar. `nil` = estado vazio (pontilhado).
    let photo: Image?

    /// Altura do card. A largura ocupa todo o espaço disponível.
    var height: CGFloat = 282

    /// Arredondamento dos cantos.
    var cornerRadius: CGFloat = 26

    var body: some View {
        content
            .frame(maxWidth: .infinity)
            .frame(height: height)
            .clipShape(.rect(cornerRadius: cornerRadius))
            .overlay {
                // Borda só no estado vazio (com foto, o protótipo não tem borda).
                if photo == nil {
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .stroke(.black, lineWidth: 1)
                }
            }
    }

    @ViewBuilder
    private var content: some View {
        if let photo {
            photo
                .resizable()
                .scaledToFill() // preenche o card, cortando as sobras
        } else {
            DotGridBackground()
        }
    }
}

// MARK: - Fundo pontilhado

/// O fundo de pontinhos do card vazio.
/// `Canvas` desenha tudo de uma vez, sem criar uma view para cada ponto. Fiz em código e não coloquei o asset em si porque talvez mude conforme o tema do projeto, mas qualquer coisa podemos trocar para um asset.
struct DotGridBackground: View {
    var spacing: CGFloat = 23
    var dotSize: CGFloat = 3

    var body: some View {
        Canvas { context, size in
            var y = spacing / 2
            while y < size.height {
                var x = spacing / 2
                while x < size.width {
                    let dot = CGRect(x: x - dotSize / 2, y: y - dotSize / 2,
                                     width: dotSize, height: dotSize)
                    context.fill(Path(ellipseIn: dot), with: .color(.gray.opacity(0.25)))
                    x += spacing
                }
                y += spacing
            }
        }
        .background(Color.white)
    }
}

// MARK: - Previews

#Preview("Vazio") {
    PhotoCard(photo: nil)
    .padding(48)
}

#Preview("Com foto") {
    PhotoCard(photo: Image(systemName: "person.crop.square.fill"))
    .padding(48)
}

#Preview("Só exibição, menor") {
    PhotoCard(
        photo: Image(systemName: "person.crop.square.fill"),
        height: 160,
        cornerRadius: 20
    )
    .padding(48)
}
