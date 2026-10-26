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
    
    let startAction: () -> Void
    let cancelAction: () -> Void
    
    var body: some View {
        VStack {
            ChallengeCircle(text: challengeTitle, size: .big)
                .offset(y: -110)
            
            Text(challengeSubTitle)
            
            Text(challengeDescription)
            
            CustomButtonComponent(title: "iniciar", icon: nil, action: startAction)
            CustomButtonComponent(title: "cancelar o desafio", icon: nil, action: cancelAction)
        }
    }
}

#Preview {
    ChallengeAcceptedView(challengeTitle: "você consegue :)", challengeSubTitle: "menos distração, mais foco", challengeDescription: "sem redes sociais, seu cardio vira um momento para cuidar do corpo e desacelerar a mente.", startAction: {}, cancelAction: {})
}
