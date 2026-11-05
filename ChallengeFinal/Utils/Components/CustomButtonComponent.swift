//
//  CustomButtonComponent.swift
//  ChallengeFinal
//
//  Created by Débora Cristina Silva Ferreira on 22/10/26.
//

import Foundation
import SwiftUI

enum CustomButtonType {
    case primary
    case secondary
    case tertiary
}

struct CustomButtonComponent: View {
    @Environment(DesignSystem.self) private var designSystem

    let title: String
    let icon: String?
    var type: CustomButtonType = .primary
    var action: () -> Void
    
    private var backgroundColor: Color {
        switch type {
        case .primary:
            return designSystem.style.colors.fillPrimary
        case .secondary:
            return Color.clear
        case .tertiary:
            return Color.clear

        }
    }
    
    private var borderColor: Color {
        switch type {
        case .secondary:
            return designSystem.style.colors.strokeDefault
        case .primary, .tertiary:
            return .clear
        }
    }
    
    private var foregroundColor: Color {
        
        switch type {
        case .primary:
            return designSystem.style.colors.textInverse
        case .secondary, .tertiary:
            return designSystem.style.colors.textPrimary
        }
        
    }
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                if let icon {
                    Image(systemName: icon)
                }
                
                Text(title)
                    .font(designSystem.style.typography.text2)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background(backgroundColor)
            .foregroundStyle(foregroundColor)
            .clipShape(RoundedRectangle(cornerRadius: 36))
            .overlay(
                RoundedRectangle(cornerRadius: 36 ).stroke(borderColor, lineWidth: 1)
            )
            .lineLimit(1)
        }.buttonStyle(.plain)
        
    }
}

#Preview {
    CustomButtonComponent(title: "arquivar", icon: "calendar", type: .primary, action: {}).environment(DesignSystem.shared)

    CustomButtonComponent(title: "arquivar", icon: "", type: .secondary, action: {})    .environment(DesignSystem.shared)

    CustomButtonComponent(title: "arquivar", icon: "calendar", type: .tertiary, action: {})    .environment(DesignSystem.shared)


}
