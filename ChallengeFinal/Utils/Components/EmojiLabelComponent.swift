//
//  EmojiLabelComponent.swift
//  ChallengeFinal
//
//  Created by Débora Cristina Silva Ferreira on 23/10/26.
//

import Foundation
import SwiftUI

struct EmojiLabelComponent: View {
    @Environment(DesignSystem.self) private var designSystem

    var humor: Humor
    var highlighted: Bool = false
    var body: some View {
        VStack(spacing: 6) {
            Image(humor.baseIcon)
                .resizable()
                .scaledToFit()
                .frame(width: highlighted ? 50: 63)
            
            Text(humor.rawValue)
                .font(designSystem.style.typography.text3)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 8)
        .padding(.bottom, 8)
        .padding(.horizontal, 8)
        .frame(minWidth: 94)
        .background {
            RoundedRectangle(cornerRadius: 12)
                .fill(highlighted ? designSystem.style.colors.backgroundPrimary : Color.clear)
        }
        .overlay {
            RoundedRectangle(cornerRadius: 8)
                .stroke(
                    highlighted ? designSystem.style.colors.strokeDefault : Color.clear,
                    lineWidth: 1.5
                )
        }
    }
}

#Preview {
    EmojiLabelComponent(humor: .pleasant, highlighted: true)    .environment(DesignSystem.shared)

    EmojiLabelComponent(humor: .veryUnpleasant, highlighted: false)    .environment(DesignSystem.shared)

}
