//
//  ChallengeDisplayView.swift
//  ChallengeFinal
//
//  Created by Paulo Henrique Costa Alves on 25/10/26.
//

import SwiftUI

struct ChallengeDisplayView: View {

    let challengeTitle: String
    let archiveAction: () -> Void
    let acceptAction: () -> Void
    let refuseAction: () -> Void

    @State private var showActions = false

    var body: some View {
        ZStack {
            // O círculo com o desafio aparece primeiro, centralizado
            ChallengeCircle(text: challengeTitle, size: .big)

            // Depois do círculo, entram o diálogo e o botão
            VStack(spacing: 24) {
                Spacer()
                ActionDialogComponent(title: "Gostaria de iniciar esse desafio?", firstOptionText: "Outra opção", secondOptionText: "aceitar", firstAction: refuseAction, secondAction: acceptAction)
                    .padding(.horizontal)

                CustomButtonComponent(title: "Arquivar desafio da lista", icon: "archivebox.fill", action: archiveAction)
            }
            .opacity(showActions ? 1 : 0)
            .offset(y: showActions ? 0 : 20)
            .allowsHitTesting(showActions)
        }
        .task {
            try? await Task.sleep(for: .seconds(0.6))
            withAnimation(.easeOut(duration: 0.4)) {
                showActions = true
            }
        }
    }
}

#Preview {
    ChallengeDisplayView(challengeTitle: "teste", archiveAction: {}, acceptAction: {}, refuseAction: {})
}
