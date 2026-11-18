//
//  CategoryCarousel.swift
//  ChallengeFinal
//
//  Created by Paulo Henrique Costa Alves on 16/11/26.
//

import SwiftUI

// Mostra o círculo da categoria atual no centro e, nas laterais, o da categoria
// anterior (esquerda) e o da próxima (direita), reduzidos e cortados pela borda da tela.
//
// Como a troca anima: a View que usa o carrossel muda `slide` de 0 para -1 (próxima)
// ou +1 (anterior) com animação. Todos os círculos andam um "slot" para o lado:
// o vizinho cresce e toma o centro, e o atual encolhe e vai para a lateral.
// Quando a animação termina, a categoria atual é trocada e `slide` volta para 0 sem animar:
// como os slots passam a mostrar as categorias novas, o resultado visual é idêntico (sem "pulo").
struct CategoryCarousel: View {
    // MARK: - Variables
    let current: ActivityCategory
    let slide: CGFloat
    let onTapCenter: () -> Void

    // Largura do círculo central (lida da própria view, para não depender do tamanho da tela)
    @State private var circleWidth: CGFloat = 0

    // Tamanho dos vizinhos em relação ao círculo central
    private let sideScale: CGFloat = 0.6
    // Distância entre os centros de dois slots, em frações da largura do círculo central
    private let spacingRatio: CGFloat = 0.63

    // MARK: - View
    var body: some View {
        // Slots -2...2: os de ±2 ficam fora da tela e só entram durante a animação.
        ZStack {
            ForEach(-2...2, id: \.self) { slot in
                circle(at: slot)
            }
        }
        .onGeometryChange(for: CGFloat.self) { $0.size.width } action: { circleWidth = $0 }
    }

    // MARK: - Private Functions
    @ViewBuilder
    private func circle(at slot: Int) -> some View {
        // Posição do slot já com o deslize atual (ex.: slot 1 com slide -1 vai para 0 = centro)
        let position = CGFloat(slot) + slide
        // Cresce até 1 no centro e fica em `sideScale` a partir de 1 slot de distância
        let scale = 0.8 - (1 - sideScale) * min(abs(position), 1)

        ChallengeCircle(category: current.shifted(by: slot), text: nil, isOpen: false)
            .scaleEffect(scale)
            .offset(x: position * spacingRatio * circleWidth)
            .onTapGesture {
                // Só o círculo central inicia a atividade
                if slot == 0 { onTapCenter() }
            }
    }
}

// MARK: - Preview
#Preview {
    CategoryCarousel(current: .physical, slide: 0, onTapCenter: {})
        .environment(DesignSystem.shared)
}
