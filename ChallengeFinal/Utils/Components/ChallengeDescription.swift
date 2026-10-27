//
//  ChallengeDescription.swift
//  ChallengeFinal
//
//  Created by Paulo Henrique Costa Alves on 26/10/26.
//

import SwiftUI

struct ChallengeDescription: View {
    
    let challengeTitle: String
    let challengeSubTitle: String
    let challengeDescription: String
    
    var body: some View {
        ChallengeCircle(text: challengeTitle, size: .small)
            .padding(.bottom, 31)
        
        Text(challengeSubTitle)
            .font(.title2)
            .bold()
            .multilineTextAlignment(.center)
            .padding(.horizontal, 82)
            .padding(.bottom, 12)
        
        Text(challengeDescription)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 42)
            .padding(.bottom, 73)
    }
}

#Preview {
    ChallengeDescription(challengeTitle: "", challengeSubTitle: "", challengeDescription: "")
}
