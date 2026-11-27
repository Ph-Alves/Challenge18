//
//  OnBoardingSecondPage.swift
//  ChallengeFinal
//
//  Created by Débora Cristina Silva Ferreira on 17/11/26.
//

import Foundation
import SwiftUI

// 2ª página: apresenta o conceito do app. O texto de baixo aparece com fade na 1ª vez.
struct OnBoardingSecondPage: View {
    @Environment(DesignSystem.self) private var designSystem
    // Indica se o fade já rodou, para não repetir ao voltar para a página
    @Binding var hasAnimated: Bool
    @State private var showBottomText = false
    
    var body: some View {
        VStack {
            VStack(spacing: 18) {
                Text("selfmaxxing.")
                    .font(designSystem.style.typography.title1)
                
                Text("pequenos desafios intencionais para sair do piloto automático")
                    .font(designSystem.style.typography.text1)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 46)
            
            Spacer()
            
            Text("e te ajudar a descobrir sua melhor versão :) ")
                .font(designSystem.style.typography.text2)
                .multilineTextAlignment(.center)
                // Já animado: aparece direto, sem animação
                .opacity(showBottomText || hasAnimated ? 1 : 0)
                .animation(hasAnimated ? nil : .easeIn(duration: 1.2), value: showBottomText)
                .padding(.horizontal, 90)
        }
        // Dispara o fade do texto de baixo
        .onAppear {
            showBottomText = true
        }
        .onDisappear {
            // Só marca como já animado ao sair, pra não cancelar a animação da 1ª vez
            hasAnimated = true
        }
    }
}

#Preview {
    OnBoardingSecondPage(hasAnimated: .constant(false)).environment(DesignSystem.shared)
}

