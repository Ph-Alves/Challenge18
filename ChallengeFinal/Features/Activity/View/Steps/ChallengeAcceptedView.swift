//
//  ChallengeAcceptedView.swift
//  ChallengeFinal
//
//  Created by Paulo Henrique Costa Alves on 26/10/26.
//

import SwiftUI

/// Step `.challenge` depois de o usuário aceitar: mostra os detalhes do desafio
/// e deixa iniciar ou cancelar.
///
/// Não conhece o Interactor nem a Store: recebe os textos prontos e avisa os toques
/// por closures, que a `ActivityView` liga ao Interactor.
struct ChallengeAcceptedView: View {

    // MARK: - Dados
    let challengeTitle: String
    let challengeSubTitle: String
    let challengeDescription: String

    // MARK: - Ações (closures)
    /// Seta de voltar: encerra o fluxo e devolve o usuário à Home.
    let returnAction: () -> Void
    /// "iniciar": segue para o step `.inProgress`.
    let startAction: () -> Void
    /// "cancelar o desafio": descarta este desafio e sorteia outro.
    let cancelAction: () -> Void

    // MARK: - View
    var body: some View {
        VStack(alignment: .center) {

            // Título, subtítulo e descrição do desafio aceito
            ChallengeDescription(challengeTitle: challengeTitle, challengeSubTitle: challengeSubTitle, challengeDescription: challengeDescription)
            
            CustomButtonComponent(title: "iniciar", icon: nil, action: startAction)
                .padding(.horizontal, 113)
            CustomButtonComponent(title: "cancelar desafio", icon: nil, type: .secondary, action: cancelAction)
                .padding(.horizontal, 113)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .overlay(alignment: .topLeading) {
            BackButton(action: returnAction)
                .padding(.horizontal)
        }
    }
}

#Preview {
    ChallengeAcceptedView(challengeTitle: "você consegue :)", challengeSubTitle: "menos distração, mais foco", challengeDescription: "sem redes sociais, seu cardio vira um momento para cuidar do corpo e desacelerar a mente.", returnAction: {}, startAction: {}, cancelAction: {})
}
