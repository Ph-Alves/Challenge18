//
//  DrawChallengeView.swift
//  ChallengeFinal
//
//  Created by Paulo Henrique Costa Alves on 23/10/26.
//

import SwiftUI

// MARK: - View
struct DrawChallengeView: View {
    
    // MARK: - Variables
    var isSearching: Bool
    var isChallengeReady: Bool
    var swipeRaffle: () -> Void
    var startDetection: () -> Void
    var finishDetection: () -> Void
    var returnAction: () -> Void
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
