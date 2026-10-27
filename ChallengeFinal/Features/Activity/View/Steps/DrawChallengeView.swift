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
    /// Seta de voltar: encerra o fluxo e devolve o usuário à Home.
    var returnAction: () -> Void
    /// Fim da animação da bola: avança para o step `.challenge`.
    var growFinished: () -> Void

    // MARK: - View
    var body: some View {
        VStack(alignment: .center, spacing: isSearching ? 0 : 66) {
            
            if !isSearching {
                VStack {
                    Text("Atrás de um novo desafio?")
                        .font(.title.bold())
                        .multilineTextAlignment(.center)
                        .contentTransition(.opacity)
                    Text("chacoalhe seu iphone e desafie-se")
                }
                .padding(.horizontal, 40)
                .animation(.easeInOut, value: isSearching)
            }

            ChallengeCircle(text: isSearching ? "Procurando um novo desafio..." : "Pode me chacoalhar :)", size: .medium)
                // Alternativa ao shake: só conta o deslize predominantemente horizontal,
                // para não confundir com rolagem ou toques acidentais na vertical.
                .gesture(
                    DragGesture(minimumDistance: 20)
                        .onEnded { value in
                            let isHorizontalSwipe = abs(value.translation.width) > abs(value.translation.height)
                            if isHorizontalSwipe {
                                swipeRaffle()
                            }
                        }
                )
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity) // centraliza na tela toda
        .overlay(alignment: .topLeading) {
            BackButton(action: returnAction)
                .padding(.horizontal)
        }
        .padding(.horizontal)
        // O acelerômetro só fica ligado enquanto a tela está visível.
        .onAppear {
            startDetection()
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
    DrawChallengeView(isSearching: true, isChallengeReady: false, swipeRaffle: {}, startDetection: {}, finishDetection: {}, returnAction: {}, growFinished: {})
}

#Preview("Shake") {
    DrawChallengeView(isSearching: false, isChallengeReady: false, swipeRaffle: {}, startDetection: {}, finishDetection: {}, returnAction: {}, growFinished: {})
}
