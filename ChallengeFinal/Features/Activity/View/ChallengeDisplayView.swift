//
//  ChallengeDisplayView.swift
//  ChallengeFinal
//
//  Created by Paulo Henrique Costa Alves on 25/10/26.
//

import SwiftUI

struct ChallengeDisplayView: View {

    let challengeTitle: String
    /// Um novo desafio está sendo gerado por baixo dos panos (reroll).
    let isSearching: Bool
    let returnAction: () -> Void
    let archiveAction: () -> Void
    let acceptAction: () -> Void
    let refuseAction: () -> Void

    @State private var elevateCircle = false
    @State private var showActions = false

    var body: some View {
        VStack {
            
            Spacer()
            ZStack {
                // O círculo com o desafio aparece primeiro, centralizado
                ChallengeCircle(text: isSearching ? "Procurando um novo desafio..." : challengeTitle, size: .big)
                    .offset(y: elevateCircle ? -120 : 0)
                
                // Depois do círculo, entram o diálogo e o botão
                VStack(spacing: 24) {
                    Spacer()
                    ActionDialogComponent(title: "Gostaria de iniciar esse desafio?", firstOptionText: "Outra opção", secondOptionText: "aceitar", firstAction: refuseAction, secondAction: acceptAction)
                        .padding(.horizontal)
                    
                    CustomButtonComponent(title: "Arquivar desafio da lista", icon: "archivebox.fill", action: archiveAction)
                        .padding(.horizontal, 70)
                    Spacer()
                }
                .opacity(showActions ? 1 : 0)
                .offset(y: showActions ? 0 : 20)
                .allowsHitTesting(showActions)
            }
            // Esconde as ações enquanto procura e mostra de novo quando o desafio chega.
            .task(id: isSearching) {
                guard !isSearching else {
                    withAnimation(.easeOut(duration: 0.2)) { showActions = false }
                    return
                }
                // Na primeira vez espera o círculo subir; nos rerolls ele já está no lugar.
                let isFirstTime = !elevateCircle
                withAnimation(.easeOut(duration: 0.8)) {
                    elevateCircle = true
                }
                try? await Task.sleep(for: .seconds(isFirstTime ? 1.5 : 0.3))
                withAnimation(.easeOut(duration: 0.4)) {
                    showActions = true
                }
            }
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity) // centraliza na tela toda
        .overlay(alignment: .topLeading) {
            BackButton(action: returnAction)
                .padding(.horizontal)
        }
    }
}

#Preview {
    ChallengeDisplayView(challengeTitle: "teste", isSearching: false, returnAction: {}, archiveAction: {}, acceptAction: {}, refuseAction: {})
}
