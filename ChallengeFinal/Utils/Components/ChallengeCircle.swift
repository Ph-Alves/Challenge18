//
//  ChallengeCircle.swift
//  ChallengeFinal
//
//  Created by Paulo Henrique Costa Alves on 22/10/26.
//

import SwiftUI

struct ChallengeCircle: View {
    
    //MARK: - Variações do ChallengeCircle
    //faço essa diferenciação porque o asset do theme Pop! não é o defaultClosed no carrossel da home.
    enum Variant {
        case standard       // defaultClosed
        case homeCarousel   // carrossel da Home
    }
    
    // MARK: - Variables
    @Environment(DesignSystem.self) private var designSystem
    
    let category: ActivityCategory
    let text: String?
    let isOpen: Bool
    var variant: Variant = .standard
    
    //aqui é a diferenciação, se a variant = homeCarousel, então minha var categoryIcon recebe category.homeCarousel
    private var categoryIcon: String {
        switch variant {
        case .standard:     category.defaultClosed
        case .homeCarousel: category.homeCarousel
        }
    }
    
    // Tamanho fixo do ícone fechado, independente do tamanho do PNG de cada tema
    // (os assets do Pop são bem maiores que os do Sober e estouravam a tela)
    static let closedIconSize: CGFloat = 346
    
    private var textLayout: CGSize {
        switch category {
        case .cognitive:
            return CGSize(width: -50, height: 20)
        case .physical:
            return CGSize(width: 0, height: 0)
        case .sensorial:
            return CGSize(width: 30, height: -35)
        case .social:
            return CGSize(width: 60, height: -70)
        }
    }
    
    private var textColor: Color {
        switch category {
        case .cognitive:
            return designSystem.style.colors.textInverse
        case .physical, .sensorial, .social:
            return designSystem.style.colors.textPrimary
        }
    }
    
    private var textWidth: CGFloat {
        switch category {
        case .physical:
            return 216
        case .cognitive, .sensorial, .social:
            return 224
        }
    }

    // MARK: - View
    var body: some View {
        ZStack(alignment: .center) {
            if isOpen {
                Image(category.defaultOpen)
            } else {
                Image(categoryIcon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: Self.closedIconSize, height: Self.closedIconSize)
            }
            
            if let text, isOpen {
                Text(text)
                    .font(designSystem.style.typography.text1)
                    .foregroundStyle(textColor)
                    .frame(maxWidth: textWidth)
                    .multilineTextAlignment(.center)
                    .offset(textLayout)
            }
        }
    }
}

// MARK: - Preview
#Preview {
    ChallengeCircle(category: .sensorial, text: "faça o seu cárdio sem abrir redes sociais", isOpen: true)
        .environment(DesignSystem.shared)
}
