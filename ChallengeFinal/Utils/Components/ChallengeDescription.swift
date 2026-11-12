//
//  ChallengeDescription.swift
//  ChallengeFinal
//
//  Created by Paulo Henrique Costa Alves on 26/10/26.
//

import SwiftUI

struct ChallengeDescription: View {
    @Environment(DesignSystem.self) private var designSystem
    
    let challengeIcon: String
    let challengeTitle: String
    let challengeSubTitle: String
    let challengeDescription: String
    var spacingBetween: CGFloat = 76
    
    var body: some View {
        VStack(spacing: spacingBetween) {
            HStack{
                Image(challengeIcon)
                    .resizable()
                    .frame(width: 64, height: 64)

                
                Text(challengeTitle)
                    .font(designSystem.style.typography.text2)
                    .foregroundStyle(designSystem.style.colors.textInverse)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 32)
            .frame(maxWidth: 312)
            .background(RoundedRectangle(cornerRadius: 12).fill(designSystem.style.colors.fillPrimary))
            
            
            VStack(spacing: 12) {
                Text(challengeSubTitle)
                    .font(designSystem.style.typography.title2)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(designSystem.style.colors.textPrimary)
                
                Text(challengeDescription)
                    .font(designSystem.style.typography.text2)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(designSystem.style.colors.textPrimary)
            }
            .padding(.horizontal, 54)
        }
       
    }
}

#Preview {
    ChallengeDescription(challengeIcon: ActivityCategory.social.cardIcon, challengeTitle: "faça o seu cárdio", challengeSubTitle: "Menos distracao, mais foco", challengeDescription: "jeifjciejceijciecowdcinoicnedincicainispaimdcpamoinsmdinaindainidsiw").environment(DesignSystem.shared)
}
