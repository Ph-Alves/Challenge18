//
//  OnBoardingSecondPage.swift
//  ChallengeFinal
//
//  Created by Débora Cristina Silva Ferreira on 17/11/26.
//

import Foundation
import SwiftUI

struct OnBoardingThir: View {
    @Environment(DesignSystem.self) private var designSystem
    @State var showBottomText = false

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
                .opacity(showBottomText ? 1 : 0)
                .animation(.easeIn(duration: 1.2), value: showBottomText)
                .padding(.horizontal, 90)

        }
        .onAppear {
            showBottomText = true
        }

    }
}

#Preview {
    OnBoardingSecondPage().environment(DesignSystem.shared)
}
