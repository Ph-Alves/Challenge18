//
//   ActionDialogComponent.swift
//  ChallengeFinal
//
//  Created by Débora Cristina Silva Ferreira on 22/10/26.
//

import Foundation
import SwiftUI

struct ActionDialogComponent: View {
    var title: String
    var firstOptionText: String
    var secondOptionText: String
    
    var firstAction: () -> Void
    var secondAction: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Text(title)
                .font(.title2)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            
            HStack(spacing: 18) {
                
                CustomButtonComponent(
                    title: firstOptionText,
                    icon: nil,
                    type: .secondary,
                    action: firstAction
                    
                )
                
                CustomButtonComponent(
                    title: secondOptionText,
                    icon: nil,
                    type: .primary,
                    action: secondAction
                    
                )
                
            }
        }
        .padding(30)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.black, lineWidth: 1)
        )
        
    }
}

#Preview {
    ActionDialogComponent(
        title: "gostaria de iniciar esse desafio?",
        firstOptionText: "Cancelar",
        secondOptionText: "Arquivar",
        firstAction: {
        },
        secondAction: {
        }
    )
    .padding()
}
