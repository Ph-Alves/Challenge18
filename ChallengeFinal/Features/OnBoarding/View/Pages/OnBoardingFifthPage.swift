//
//  OnBoardingFifthPage.swift
//  ChallengeFinal
//
//  Created by Débora Cristina Silva Ferreira on 23/11/26.
//

import Foundation
import SwiftUI

// 5ª página: encerramento, com o botão que leva ao app.
struct OnBoardingFifthPage: View {
    @Environment(DesignSystem.self) private var designSystem
    // Chamado ao tocar em "desafie-se"
    let onFinish: () -> Void
    
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
            
            // Botão final
            CustomButtonComponent(title: "desafie-se", icon: nil, type: .primary, action:  onFinish )
                .padding(.horizontal, 120)
        }
        
    }
}

#Preview {
    OnBoardingFifthPage(onFinish: { }).environment(DesignSystem.shared)
}
