//
//  EmojiLabelComponent.swift
//  ChallengeFinal
//
//  Created by Débora Cristina Silva Ferreira on 23/10/26.
//

import Foundation
import SwiftUI

struct EmojiLabelComponent: View {
    var humor: Humor
    var highlighted: Bool = false
    var body: some View {
        VStack(spacing: 6) {
            Image(humor.icon)
                .resizable()
                .scaledToFit()
                .frame(width: highlighted ? 50: 63)
            
            Text(humor.rawValue)
                .fontWeight(.bold)
                .font(highlighted ? .subheadline: .callout)
            
        }
        
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background {
            RoundedRectangle(cornerRadius: 12)
                .fill(highlighted ? Color.white : Color.clear)
            
        }
        .overlay {
            RoundedRectangle(cornerRadius: 14)
                .stroke(
                    highlighted ? Color.black : Color.clear,
                    lineWidth: 1.5
                )
            
        }
    }
}

#Preview {
    EmojiLabelComponent(humor: .frustrated, highlighted: true)
    EmojiLabelComponent(humor: .frustrated, highlighted: false)
}
