//
//  OnBoardingView.swift
//  ChallengeFinal
//
//  Created by Débora Cristina Silva Ferreira on 17/11/26.
//

import Foundation
import SwiftUI

struct OnboardingView: View {
    @State private var currentPage = 0
    @Environment(DesignSystem.self) private var designSystem
    @Namespace private var heroNamespace
    @State private var goingForward = true
    @State private var secondPageAnimated = false
    @State private var selectedCategory: ActivityCategory? = .physical
    
    private let numberOfPages = 5
    
    private func go(to page: Int) {
        guard page != currentPage, (0..<numberOfPages).contains(page) else { return }
        goingForward = page > currentPage
        
        // Ao sair da 4ª página, volta o scroll pro ícone ancorado (sem animar)
        if currentPage == 3, page < 3 {
            var transaction = Transaction()
            transaction.disablesAnimations = true
            withTransaction(transaction) { selectedCategory = .physical }
        }
        
        DispatchQueue.main.async {
            withAnimation(.easeInOut(duration: 0.5)) { currentPage = page }
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Botão pular
            HStack {
                Spacer()
                Button {
                    
                } label: {
                    Text("pular")
                        .font(designSystem.style.typography.text2)
                        .foregroundStyle(designSystem.style.colors.textPrimary)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 50)
            .padding(.vertical)
            
            ZStack {
                switch currentPage {
                case 0:
                    OnBoardingFirstPage()
                        .transition(.identity)
                    
                case 1:
                    OnBoardingSecondPage(hasAnimated: $secondPageAnimated)
                        .padding(.top, 168)
                        .padding(.bottom, 100)
                        .transition(.identity)
                    
                case 2:
                    OnBoardingThirdPage(namespace: heroNamespace)
                        .padding(.top, 38)
                        .padding(.bottom, 92)
                        .transition(.asymmetric(
                            insertion: goingForward ? .identity : .opacity,
                            removal: goingForward ? .identity : .identity
                        ))
                case 3:
                    OnBoardingFourthPage(selectedCategory: $selectedCategory, namespace: heroNamespace)
                        .transition(.asymmetric(
                            insertion: goingForward ? .identity : .opacity,
                            removal: goingForward ? .identity : .identity
                        ))
                    
                case 4:
                    OnBoardingFifthPage()
                        .transition(.identity)

                default:
                    OnBoardingFirstPage()
                        .transition(.identity)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 30).onEnded { value in
                    guard abs(value.translation.width) > abs(value.translation.height) else { return }
                    let swipedLeft = value.translation.width < 0
                    let swipedRight = value.translation.width > 0
                    
                    if swipedLeft, currentPage < numberOfPages - 1 { go(to: currentPage + 1) }
                    if swipedRight, currentPage > 0 { go(to: currentPage - 1) }
                }
            )
            
            OnboardingPageControl(
                currentPage: Binding(get: { currentPage }, set: { go(to: $0) }),
                numberOfPages: numberOfPages
            )
            .padding(.horizontal, 58)
            .padding(.vertical)
        }
    }
}

// mesmo arquivo: só aplica o matched quando for o ícone de movimento
extension View {
    @ViewBuilder
    func hero(_ isHero: Bool, in namespace: Namespace.ID) -> some View {
        if isHero {
            matchedGeometryEffect(id: "hero", in: namespace)
        } else {
            self
        }
    }
}

#Preview {
    OnboardingView().environment(DesignSystem.shared)
}
