//
//  StreakCard.swift
//  ChallengeFinal
//
//  Created by Raquel Souza on 17/11/26.
//

import SwiftUI

struct StreakProfileCard: View {
    @Environment(DesignSystem.self) private var designSystem


    let streakDateCount: String
    let title: String
    let subtitle: String

    private var typography: Typography { designSystem.style.typography }
    private var colors: ColorPalette { designSystem.style.colors }
    private var icon: IconsSet { designSystem.style.icons }


    var body: some View {
        HStack(spacing: 28) {
            VStack(spacing: 6) {
                Image(icon.streakIcon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 44, height: 44)
                Text(streakDateCount)
                    .font(typography.subtitle3)
                    .lineLimit(1)
            }
            .frame(width: 64, height: 75)

            VStack(spacing: 8) {
                Text(title)
                    .font(typography.subtitle3)
                Text(subtitle)
                    .font(typography.text3)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: 167)
        }
        .foregroundStyle(colors.fillConstantLight)
        .padding(.vertical, 12)
//        .padding(.horizontal, 18)
        .frame(maxWidth: 333, minHeight: 91)
        .background(colors.fillConstantDark)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(colors.fillConstantLight, lineWidth: 1))
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    ZStack {
        Color.pink.ignoresSafeArea()
        StreakProfileCard(streakDateCount: "07 dias", title: "lenda da consistência",
                   subtitle: "07 dias priorizando seu bem estar!")
            .padding()
            .environment(DesignSystem.shared)
    }
}
