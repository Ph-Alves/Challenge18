//
//   ActionDialogComponent.swift
//  ChallengeFinal
//
//  Created by Débora Cristina Silva Ferreira on 22/10/26.
//

import Foundation
import SwiftUI

enum TitleStyle {
    case large
    case timer
    
}

struct ActionDialogComponent: View {
    @Environment(DesignSystem.self) private var designSystem

    var title: String
    var titleStyle: TitleStyle = .large

    var firstOptionText: String?
    var secondOptionText: String?
    
    var firstAction: () -> Void
    var secondAction: () -> Void
    
    var firstIcon: String? = nil
    var secondIcon: String? = nil
    
    var body: some View {
        VStack(spacing: 22) {
            Text(title)
                .font(titleStyle == .large ? designSystem.style.typography.title3 : designSystem.style.typography.text4.bold())
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            

            HStack(spacing: 20) {
                CustomButtonComponent(
                    title: firstOptionText,
                    icon: firstIcon,
                    type: .secondary,
                    action: firstAction
                )
                
                CustomButtonComponent(
                    title: secondOptionText ,
                    icon: secondIcon,
                    type: .primary,
                    action: secondAction
                )
                
            }

        }
        .padding(.vertical,24)
        .padding(.horizontal,30)
        .background(designSystem.style.colors.backgroundPrimary)

        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(designSystem.style.colors.strokeDefault, lineWidth: 1)
        )
        
    }
}

#Preview {
    ActionDialogComponent(
        title: "gostaria de iniciar esse desafio?",
        firstOptionText: "outro desafio",
        secondOptionText: "aceitar",
        firstAction: {
        },
        secondAction: {
        }
    )
    .padding()
    .environment(DesignSystem.shared)
}
