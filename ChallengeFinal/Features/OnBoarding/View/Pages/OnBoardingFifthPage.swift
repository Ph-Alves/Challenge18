//
//  OnBoardingFifthPage.swift
//  ChallengeFinal
//
//  Created by Débora Cristina Silva Ferreira on 23/11/26.
//

import Foundation
import SwiftUI

struct OnBoardingFifthPage: View {
    @Environment(DesignSystem.self) private var designSystem

    var body: some View {
        VStack(spacing: 57){
            
            
            VStack(spacing: 24) {
                Text("já sabe qual categoria você se encaixa mais?").font(designSystem.style.typography.title2)
                    .multilineTextAlignment(.center)
                
                Text("abra o app e encontre seu primeiro desafio :)")
                    .font(designSystem.style.typography.text1)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 48)
            
            CustomButtonComponent(title: "desafie-se", icon: nil, type: .primary, action: { })
                .padding(.horizontal, 120)
        }
        
    }
}

#Preview {
    OnBoardingFifthPage().environment(DesignSystem.shared)
}
