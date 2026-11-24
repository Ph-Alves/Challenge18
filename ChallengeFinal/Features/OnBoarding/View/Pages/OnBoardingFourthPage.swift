//
//  OnBoardingFourthPage.swift
//  ChallengeFinal
//
//  Created by Débora Cristina Silva Ferreira on 17/11/26.
//

import Foundation
import SwiftUI

// Mostra cada categoria com o mesmo swipe horizontal da Home.
struct OnBoardingFourthPage: View {

    // MARK: - Variables

    @Environment(DesignSystem.self) private var designSystem

    // Categoria exibida (local, o onboarding não tem Store)
    @State private var currentCategory: ActivityCategory = ActivityCategory.allCases[0]

    // Estado da animação do círculo no swipe
    @State private var imageOffset: CGFloat = 0
    @State private var imageOpacity: Double = 1
    @State private var isAnimatingSwipe = false

    // MARK: - Animation

    // Troca a categoria: a imagem atual sai para o lado do swipe
    // e a nova entra vindo do lado oposto.
    private func changeCategory(towardsNext: Bool) {
        guard !isAnimatingSwipe else { return }

        let categories = ActivityCategory.allCases
        guard let index = categories.firstIndex(of: currentCategory) else { return }
        let newIndex = index + (towardsNext ? 1 : -1)
        // Sem loop: para na primeira/última categoria
        guard categories.indices.contains(newIndex) else { return }

        isAnimatingSwipe = true
        // Swipe para esquerda (próxima): sai pela esquerda, entra pela direita
        let distance: CGFloat = towardsNext ? -200 : 200

        withAnimation(.easeIn(duration: 0.15)) {
            imageOffset = distance
            imageOpacity = 0
        }

        Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(150))
            currentCategory = categories[newIndex]
            // Reposiciona do lado oposto sem animar
            var transaction = Transaction(animation: nil)
            transaction.disablesAnimations = true
            withTransaction(transaction) {
                imageOffset = -distance
            }
            withAnimation(.spring(duration: 0.3)) {
                imageOffset = 0
                imageOpacity = 1
            }
            isAnimatingSwipe = false
        }
    }

    // MARK: - View

    var body: some View {
        VStack(spacing: 10) {
            Spacer()

            VStack {
                // Circulo da categoria com gesture de swipe (esquerda/direita)
                ChallengeCircle(category: currentCategory, text: nil, isOpen: false)
                    .gesture(
                        DragGesture(minimumDistance: 20)
                            .onEnded { value in
                                // Se width > height, então é horizontal
                                let isHorizontalSwipe = abs(value.translation.width) > abs(value.translation.height)
                                guard isHorizontalSwipe else { return }
                                // Negativo: direita para esquerda (próxima)
                                changeCategory(towardsNext: value.translation.width < 0)
                            }
                    )
                    .offset(x: imageOffset)
                    .opacity(imageOpacity)

                // Texto da respectiva categoria
                CategoryText(category: currentCategory)
                    .font(designSystem.currentTheme.style.typography.title3)
            }

            Spacer()

            // Indicador de categoria: a barra da categoria atual fica maior
            HStack(spacing: 10) {
                ForEach(ActivityCategory.allCases, id: \.self) { category in
                    let isSelected = category == currentCategory
                    Capsule()
                        .frame(width: isSelected ? 5 : 2, height: isSelected ? 20 : 14)
                }
            }
            .frame(height: 20)
            .animation(.easeInOut(duration: 0.2), value: currentCategory)

            Spacer()
        }
        .padding(.vertical)
    }
}

#Preview {
    OnBoardingFourthPage()
        .environment(DesignSystem.shared)
}
