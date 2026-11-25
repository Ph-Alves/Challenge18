//
//  OnBoardingView.swift
//  ChallengeFinal
//
//  Created by Débora Cristina Silva Ferreira on 17/11/26.
//

import Foundation
import SwiftUI

// MARK: - Controla qual página aparece e o swipe entre elas.
struct OnboardingView: View {
    // MARK: - Variables

    // Página atual (0 a 4)
    @State private var currentPage = 0
    
    // DesignSystem
    @Environment(DesignSystem.self) private var designSystem
    
    // Namespace compartilhado entre as páginas 3 e 4 para o efeito "hero" das categorias
    @Namespace private var heroNamespace
    
    // Direção da última troca de página, usada para escolher a transição
    @State private var goingForward = true
    
    // Evita repetir a animação do texto da 2ª página ao voltar para ela
    @State private var secondPageAnimated = false
    
    // Categoria exibida na 4ª página
    @State private var selectedCategory: ActivityCategory? = .physical
    
    // numero total de paginas para o onBoardingPageControl
    private let numberOfPages = 5

    // Chamado ao pular ou terminar o onboarding
    let onFinish: () -> Void

    // MARK: - View

    var body: some View {
        VStack(spacing: 0) {
            // Botão pular
            HStack {
                Spacer()
                Button {
                    onFinish()
                } label: {
                    Text("pular")
                        .font(designSystem.style.typography.text2)
                        .foregroundStyle(designSystem.style.colors.textPrimary)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 50)
            .padding(.vertical)
            
            // Mostra só a página atual; as transições definem como ela entra e sai
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
                    // Ao avançar, não anima (o hero faz a transição) ao voltar, entra com fade
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
                        .padding(.top, 86)
                    
                    Spacer()
                    
                case 4:
                    OnBoardingFifthPage(onFinish: onFinish)
                        .transition(.identity)

                default:
                    OnBoardingFirstPage()
                        .transition(.identity)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            // Faz a área toda responder ao gesto, mesmo onde não há conteúdo
            .contentShape(Rectangle())
            
            // Swipe lateral para trocar de página
            .gesture(
                DragGesture(minimumDistance: 30).onEnded { value in
                    // Ignora gestos mais verticais que horizontais
                    guard abs(value.translation.width) > abs(value.translation.height) else { return }
                    // Negativo: direita para esquerda (próxima).
                    // Positivo: esquerda para direita (anterior)
                    let swipedLeft = value.translation.width < 0
                    let swipedRight = value.translation.width > 0
                    
                    if swipedLeft, currentPage < numberOfPages - 1 { go(to: currentPage + 1) }
                    if swipedRight, currentPage > 0 { go(to: currentPage - 1) }
                }
            )
            
            // Setas e indicadores
            OnboardingPageControl(
                currentPage: currentPage,
                numberOfPages: numberOfPages,
                onBack: { go(to: currentPage - 1) },
                onNext: { go(to: currentPage + 1) }
            )
            .padding(.horizontal, 58)
            .padding(.vertical)
        }
    }
    
    // MARK: - Actions

    // Troca de página, definindo antes a direção para a transição usar o lado certo
    private func go(to page: Int) {
        guard page != currentPage, (0..<numberOfPages).contains(page) else { return }
        goingForward = page > currentPage

        // Ao entrar na 4ª página, reseta a categoria sem animar
        if page == 3 {
            var transaction = Transaction()
            transaction.disablesAnimations = true
            withTransaction(transaction) { selectedCategory = .physical }
        }

        // Adia a troca para o próximo ciclo, depois da mudança de estado acima
        Task { @MainActor in
            withAnimation(.easeInOut(duration: 0.5)) { currentPage = page }
        }
    }
}



extension View {
    // Atalho para o matchedGeometryEffect usando a categoria como id,
    // assim o ícone "viaja" da 3ª para a 4ª página
    func hero(_ category: ActivityCategory, in namespace: Namespace.ID) -> some View {
        matchedGeometryEffect(id: category, in: namespace)
    }
}

#Preview {
    OnboardingView(onFinish: { }).environment(DesignSystem.shared)
}
