//
//  OnBoardingSecondPage.swift
//  ChallengeFinal
//
//  Created by Débora Cristina Silva Ferreira on 17/11/26.
//

import Foundation
import SwiftUI

// 3ª página: mostra as 4 categorias. Os ícones usam o efeito "hero"
// para virar o círculo da 4ª página.
struct OnBoardingThirdPage: View {
    @Environment(DesignSystem.self) private var designSystem
    @State var showBottomText = false
    // Namespace compartilhado com a 4ª página
    let namespace: Namespace.ID

    var body: some View {
        VStack {
            VStack(spacing: 44) {
                
                Text("você pode se desafiar\n\((Text("(e refletir)").font(designSystem.style.typography.title3))) em 4 categorias")
                        .font(designSystem.style.typography.text1)
                        .multilineTextAlignment(.center)
               
                // Um ícone por categoria
                VStack {
                    ForEach(ActivityCategory.allCases, id: \.self) { category in
                        VStack(spacing: 24) {
                            Image(category.defaultClosed)
                                .resizable()
                                .scaledToFit()
                                .hero(category, in: namespace)

                                
                            
                        }
                    }
                   
                }

            }
            .padding(.horizontal, 68)
        }
        .onAppear {
            showBottomText = true
        }

    }
}

#Preview {
    @Previewable @Namespace var ns
    OnBoardingThirdPage(namespace: ns).environment(DesignSystem.shared)
}

