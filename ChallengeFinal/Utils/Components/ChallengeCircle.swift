//
//  ChallengeCircle.swift
//  ChallengeFinal
//
//  Created by Paulo Henrique Costa Alves on 22/10/26.
//

import SwiftUI

struct ChallengeCircle: View {
    // MARK: - Variables
    @Environment(DesignSystem.self) private var designSystem
    
    let category: ActivityCategory
    let text: String
    
    private var TextLayout: CGSize {
        switch category {
        case .cognitive:
            return CGSize(width: -30, height: 40)
        case .physical:
            return CGSize(width: 30, height: 40)
        case .sensorial:
            return CGSize(width: 30, height: -45)
        case .social:
            return CGSize(width: 30, height: 40)
        }
    }

    // MARK: - View
    var body: some View {
        ZStack(alignment: .center) {
            Image(category.openIcon)

            Text(text)
                .foregroundStyle(.red)
                .multilineTextAlignment(.center)
                .offset(TextLayout)
        }
    }
}

// MARK: - Preview
#Preview {
    ChallengeCircle(category: .sensorial, text: "Descubra sua própria mão.")
        .environment(DesignSystem.shared)
}
