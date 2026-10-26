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
    
    let title: String
    let icon: String?
    var type: CustomButtonType = .primary
    var action: () -> Void = {}
    
    private var backgroundColor: Color {
        switch type {
        case .primary:
            return Color._404040
        case .secondary:
            return Color.E_0_E_0_E_0
        case .tertiary:
            return Color.F_4_F_4_F_4
            
        }
        
    }
    
    private var foregroundColor: Color {
        
        switch type {
        case .primary:
            return .white
        case .secondary, .tertiary:
            return .black
        }
        
    }
    var body: some View {
        Button(action: action) {
            HStack(spacing: 5) {
                if let icon {
                    Image(systemName: icon)
                }
                
                Text(title)
            }
            .font(.body)
            .padding(.horizontal, 20)
            .padding(.vertical, 5)
            .frame(maxWidth: .infinity)
            .background(backgroundColor)
            .foregroundStyle(foregroundColor)
            .clipShape(.capsule)
            .lineLimit(1)
        }.buttonStyle(.plain)
        
    }
}

#Preview {
    CustomButtonComponent(title: "arquivar", icon: "calendar", type: .primary)
}
