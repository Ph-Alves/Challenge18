//
//  CategoryFilterButton.swift
//  ChallengeFinal
//
//  Created by Raquel Souza on 03/11/26.
//

import SwiftUI

struct CategoryFilterButton: View {
    @Environment(DesignSystem.self) private var designSystem
    
    let category: ActivityCategory
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(category.defaultClosed)
                    .resizable()
                    .frame(width: 63, height: 63)

                Text(category.text)
                    .font(designSystem.style.typography.text3)
                    .foregroundStyle(designSystem.style.colors.textPrimary)
                    .fontWeight(isSelected ? .semibold : .regular)
            }
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("filtrar por \(category.text)")
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

#Preview("Sober") {
    let designSystem = DesignSystem.shared
    designSystem.currentTheme = .sober

    return CategoryFilterButton(category: .cognitive, isSelected: false, action: { print("click") })
        .environment(designSystem)
}

#Preview("Pop") {
    let designSystem = DesignSystem.shared
    designSystem.currentTheme = .pop

    return CategoryFilterButton(category: .cognitive, isSelected: true, action: { print("click") })
        .environment(designSystem)
}
