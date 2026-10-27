//
//  DrawChallengeView.swift
//  ChallengeFinal
//
//  Created by Paulo Henrique Costa Alves on 23/10/26.
//

import SwiftUI

struct DrawChallengeView: View {
    
    var isSearching: Bool
    var isChallengeReady: Bool
    var startDetection: () -> Void
    var finishDetection: () -> Void
    var returnAction: () -> Void
    var growFinished: () -> Void

    var body: some View {
        VStack(alignment: .center, spacing: isSearching ? 0 : 66) {
            Spacer()
            
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

            Spacer()
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

#Preview {
    DrawChallengeView(isSearching: true, isChallengeReady: false, startDetection: {}, finishDetection: {}, returnAction: {}, growFinished: {})
}
