//
//  DrawChallengeView.swift
//  ChallengeFinal
//
//  Created by Paulo Henrique Costa Alves on 23/10/26.
//

import SwiftUI

struct DrawChallengeView: View {
    
    var returnAction: () -> Void
    
    var body: some View {
        VStack(spacing: 66) {
            HStack {
                BackButton(action: returnAction)
                    .padding(.bottom, 24)
                Spacer()
            }
            
            VStack {
                Text("Atrás de um novo desafio?")
                    .font(.title.bold())
                    .multilineTextAlignment(.center)
                Text("chacoalhe seu iphone e desafie-se")
            }
            .padding(.horizontal, 40)
            
            ChallengeCircle(text: "Pode me chacoalhar :)", size: .medium)
            
            Spacer()
        }
        .padding(.horizontal)
    }
}

#Preview {
    DrawChallengeView(returnAction: {})
}
