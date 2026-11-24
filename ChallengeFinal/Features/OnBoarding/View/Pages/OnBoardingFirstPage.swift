//
//  OnBoardingFirstPage.swift
//  ChallengeFinal
//
//  Created by Débora Cristina Silva Ferreira on 17/11/26.
//

import Foundation
import SwiftUI

// 1ª página: saudação oi.
struct OnBoardingFirstPage: View {
    @Environment(DesignSystem.self) private var designSystem

    var body: some View {
        Text("oi!")
            .font(designSystem.style.typography.title1)
    }
}

#Preview {
    OnBoardingFirstPage().environment(DesignSystem.shared)
}
