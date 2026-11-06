//
//  HumorIconBadge.swift
//  ChallengeFinal
//
//  Created by Rebeca Maria de Morais Guimães on 06/11/26.
//

import Foundation
import SwiftUI

struct HumorIconBadge: View {
    @Environment(DesignSystem.self) private var designSystem
    let humor: Humor
    var size: CGFloat

    var body: some View {
        
        Image(humor.cardIcon)
            .resizable()
            .frame(width: size, height: size)
            .padding(8)
            .background(
                RoundedRectangle(cornerRadius: 6).fill(designSystem.style.colors.emotionBGFill)
            )
    }
}
