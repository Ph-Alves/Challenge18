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

    @State private var ballScale: CGFloat = 0
    @State private var contentOpacity: Double = 1

    var body: some View {
        VStack(spacing: 66) {
            HStack {
                BackButton(action: returnAction)
                    .padding(.bottom, 24)
                    .opacity(contentOpacity)
                Spacer()
            }

            VStack {
                Text("Atrás de um novo desafio?")
                    .font(.title.bold())
                    .multilineTextAlignment(.center)
                    .contentTransition(.opacity)
                if !isSearching {
                    Text("chacoalhe seu iphone e desafie-se")
                }
            }
            .padding(.horizontal, 40)
            .opacity(contentOpacity)
            .animation(.easeInOut, value: isSearching)

            ChallengeCircle(text: isSearching ? "Procurando um novo desafio..." : "Pode me chacoalhar :)", size: .medium)
                .scaleEffect(ballScale)
            
            Spacer()
        }
        .padding(.horizontal)
        .onAppear {
            startDetection()
        }
        .onChange(of: isChallengeReady) { _, ready in
            guard ready else { return }
            // Bola cresce até preencher a tela e só então avança para o desafio
            withAnimation(.easeIn(duration: 0.6)) {
                ballScale = 2
                contentOpacity = 0
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
    DrawChallengeView(isSearching: false, isChallengeReady: false, startDetection: {}, finishDetection: {}, returnAction: {}, growFinished: {})
}
