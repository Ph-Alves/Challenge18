//
//  ChallengeAcceptedView.swift
//  ChallengeFinal
//
//  Created by Paulo Henrique Costa Alves on 26/10/26.
//

import SwiftUI

struct ChallengeAcceptedView: View {
    
    let challengeTitle: String
    let challengeSubTitle: String
    let challengeDescription: String
    
    let returnAction: () -> Void
    let startAction: () -> Void
    let cancelAction: () -> Void

    var body: some View {
        VStack(alignment: .center) {
            
            ChallengeDescription(challengeTitle: challengeTitle, challengeSubTitle: challengeSubTitle, challengeDescription: challengeDescription)
            
            CustomButtonComponent(title: "iniciar", icon: nil, action: startAction)
                .padding(.horizontal, 113)
            CustomButtonComponent(title: "cancelar o desafio", icon: nil, action: cancelAction)
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
