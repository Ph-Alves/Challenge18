//
//  ThemeCard.swift
//  ChallengeFinal
//
//  Created by Raquel Souza on 20/11/26.
//
/*
 ///Nome do asset do ícone do tema.
 var previewIcon: String {
     switch self {
     case .sober: return SoberStyle().icons.activityIcons[.physical]?.closed ?? "eightBall"
     case .pop: return "popThemeIcon" //CHANGE: colocar asset real.
     case .bubblegum: return "bubblegumThemeIcon" //CHANGE: colocar asset real.
     case .techNature: return "techNatureThemeIcon" //CHANGE: colocar asset real.
     }
 }
 */

import SwiftUI

/// Card de tema: preto quando selecionado, branco com borda quando não.
struct ThemeCard: View {
    
    @Environment(\.colorScheme) private var colorScheme
    @Environment(DesignSystem.self) private var designSystem

    let theme: Theme
    let isSelected: Bool
    let action: () -> Void

    private var colors: ColorPalette { designSystem.style.colors }

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                icon
                    .frame(width: 40, height: 40)
                    .environment(\.colorScheme, colorScheme == .dark ? .light : .dark)
                Text(theme.displayName)
                    .font(designSystem.style.typography.subtitle3)
            }
            /*
             VStack(spacing: 4) {
                 Image(theme.previewIcon)
                     .resizable()
                     .scaledToFit()
                     .frame(width: 40, height: 40)
                 Text(theme.displayName)
                     .font(designSystem.style.typography.subtitle3)
             }
             */
            .frame(width: 80, height: 90)
            .foregroundStyle(isSelected ? colors.textInverse : colors.textPrimary)
            .background(isSelected ? colors.fillPrimary : colors.backgroundPrimary)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay(RoundedRectangle(cornerRadius: 10).stroke(colors.strokeDefault, lineWidth: 1))
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }

    /// Usa o asset do tema; enquanto ele não existir no catálogo, mostra um SF Symbol.
    @ViewBuilder
    private var icon: some View {
        if UIImage(named: theme.previewIcon) != nil {
            Image(theme.previewIcon)
                .resizable()
                .scaledToFit()
        } else {
            Image(systemName: "dice.fill")
                .resizable()
                .scaledToFit()
                .foregroundStyle(.pink)
        }
    }
}

#Preview("Selecionado e não selecionado") {
    HStack(spacing: 12) {
        ThemeCard(theme: .sober, isSelected: true, action: {})
        ThemeCard(theme: .pop, isSelected: false, action: {})
    }
    .padding(24)
    .environment(DesignSystem.shared)
}

#Preview("Seleção interativa") {
    @Previewable @State var selected: Theme = .sober
    let themes: [Theme] = [.sober, .bubblegum, .pop, .techNature]

    HStack(spacing: 12) {
        ForEach(themes, id: \.self) { theme in
            ThemeCard(theme: theme, isSelected: selected == theme) {
                selected = theme
            }
        }
    }
    .padding(24)
    .environment(DesignSystem.shared)
}
