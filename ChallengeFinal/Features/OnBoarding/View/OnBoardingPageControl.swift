//
//  OnBoardingPageControl.swift
//  ChallengeFinal
//
//  Created by Débora Cristina Silva Ferreira on 17/11/26.
//

import Foundation

import SwiftUI

// Controle de páginas do onboarding: seta voltar, indicadores e seta avançar.
struct OnboardingPageControl: View {

    // Página atual, controlada pelo OnboardingView
    let currentPage: Int
    let numberOfPages: Int
    let onBack: () -> Void
    let onNext: () -> Void

    @Environment(DesignSystem.self) private var designSystem

    // Na última página só a seta de voltar aparece; o avanço é pelo botão da própria página
    private var isLastPage: Bool { currentPage == numberOfPages - 1 }

    var body: some View {

        HStack {

            // Botão voltar (a seta avançar girada em 180°); some na primeira página
            Button {
                onBack()
            } label: {
                Image(designSystem.style.icons.nextIcon)
                    .rotationEffect(.degrees(180))
            }
            .disabled(currentPage == 0)
            .opacity(currentPage == 0 ? 0 : 1) 

            Spacer()

            if !isLastPage {
                // Indicadores: a bolinha da página atual fica destacada
                HStack(spacing: 6) {
                    ForEach(0..<numberOfPages, id: \.self) { index in

                        Circle()
                            .fill(
                                currentPage == index
                                ? designSystem.style.colors.fillPrimary
                                : designSystem.style.colors.fillPlaceholder
                            )
                            .frame(width: 8, height: 8)
                    }
                }

                Spacer()

                // Botão avançar
                Button {
                    onNext()
                } label: {
                    Image(designSystem.style.icons.nextIcon)
                }
            }
        }
        .padding(.horizontal, 24)
    }
}
