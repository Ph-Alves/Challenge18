//
//  OnBoardingPageControl.swift
//  ChallengeFinal
//
//  Created by Débora Cristina Silva Ferreira on 17/11/26.
//

import Foundation

import SwiftUI

struct OnboardingPageControl: View {
    
    @Binding var currentPage: Int
    let numberOfPages: Int
    @Environment(DesignSystem.self) private var designSystem

    private var isLastPage: Bool { currentPage == numberOfPages - 1 }

    var body: some View {

        HStack {

            Button {
                if currentPage > 0 {
                    currentPage -= 1
                }
            } label: {
                Image(designSystem.style.icons.nextIcon)
                    .rotationEffect(.degrees(180))
            }
            .disabled(currentPage == 0)
            .opacity(currentPage == 0 ? 0 : 1) 

            Spacer()

            // Na última página só sobra o botão de voltar
            if !isLastPage {
                // Indicadores
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
                    currentPage += 1
                } label: {
                    Image(designSystem.style.icons.nextIcon)
                }
            }
        }
        .padding(.horizontal, 24)
    }
}
