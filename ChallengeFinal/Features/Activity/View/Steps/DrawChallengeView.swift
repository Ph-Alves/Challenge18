//
//  DrawChallengeView.swift
//  ChallengeFinal
//
//  Created by Paulo Henrique Costa Alves on 23/10/26.
//

import SwiftUI

/// Step `.draw` do fluxo de Activity: o usuário chacoalha o iPhone (ou desliza
/// o dedo na bola) para sortear um desafio.
///
/// Não conhece o Interactor nem a Store: recebe o estado e avisa os eventos
/// por closures, que a `ActivityView` liga ao Interactor.
struct DrawChallengeView: View {

    // MARK: - Variables
    @Environment(DesignSystem.self) private var designSystem
    /// Liga enquanto `isSearching` para animar o pulso da bola.
    @State private var isPulsing = false

    /// Categoria selecionada
    var selectedCategory: ActivityCategory
    /// O sorteio está em andamento: troca os textos e esconde o título.
    var isSearching: Bool
    /// O desafio já foi sorteado: dispara a animação final e o avanço de step.
    var isChallengeReady: Bool
    /// Deslize horizontal na bola: sorteia sem precisar chacoalhar.
    var swipeRaffle: () -> Void
    /// Liga o acelerômetro (ao aparecer).
    var startDetection: () -> Void
    /// Desliga o acelerômetro (ao sair).
    var finishDetection: () -> Void
    /// Fim da animação da bola: avança para o step `.challenge`.
    var growFinished: () -> Void

    // MARK: - View
    var body: some View {
        VStack(alignment: .center, spacing: isSearching ? 0 : 28) {
            if !isSearching {
                VStack(spacing: 17) {
                    Text("atrás de um novo desafio?")
                        .font(designSystem.style.typography.title1)
                        .multilineTextAlignment(.center)
                        .contentTransition(.opacity)
                    Text("chacoalhe seu iphone e desafie-se").font(designSystem.currentTheme.style.typography.text2)
                }
                .padding(.horizontal, 40)
                .animation(.easeInOut, value: isSearching)
            }

            ChallengeCircle(category: selectedCategory, text: nil, isOpen: false)
                // Pulsa (aumenta e diminui) enquanto sorteia (isSearching); ao terminar, volta ao normal.
                .scaleEffect(isPulsing ? 1.08 : 1)
                .animation(
                    isSearching ? .easeInOut(duration: 0.6).repeatForever(autoreverses: true) : .easeOut(duration: 0.2),
                    value: isPulsing
                )
//              Alternativa ao shake: só conta o deslize predominantemente horizontal,
//              para não confundir com rolagem ou toques acidentais na vertical.
                .gesture(
                    DragGesture(minimumDistance: 20)
                        .onEnded { value in
                            let isHorizontalSwipe = abs(value.translation.width) > abs(value.translation.height)
                            if isHorizontalSwipe {
                                swipeRaffle()
                            }
                        }
                )
                .animation(.bouncy, value: isSearching)
                .padding(.bottom, isSearching ? 0 : 150)
        }
        .padding(.horizontal)
        // O acelerômetro só fica ligado enquanto a tela está visível.
        .onAppear {
            startDetection()
            isPulsing = isSearching
        }
        // O pulso começa quando o sorteio começa, não quando a view aparece.
        .onChange(of: isSearching) { _, searching in
            isPulsing = searching
        }
        .onChange(of: isChallengeReady) { _, ready in
            guard ready else { return }
            // Bola cresce até preencher a tela e só então avança para o desafio
            withAnimation(.easeIn(duration: 0.6)) {
            } completion: {
                growFinished()
            }
        }
        .onDisappear {
            finishDetection()
        }
    }
}

// MARK: - Preview

#Preview("Searching") {
    DrawChallengeView(selectedCategory: .physical, isSearching: true, isChallengeReady: false, swipeRaffle: {}, startDetection: {}, finishDetection: {}, growFinished: {})
        .environment(DesignSystem.shared)
}

#Preview("Shake") {
    DrawChallengeView(selectedCategory: .physical, isSearching: false, isChallengeReady: false, swipeRaffle: {}, startDetection: {}, finishDetection: {}, growFinished: {})
        .environment(DesignSystem.shared)
}
