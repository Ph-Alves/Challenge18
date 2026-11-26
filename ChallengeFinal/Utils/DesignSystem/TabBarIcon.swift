//
//  TabBarIconsSet.swift
//  ChallengeFinal
//
//  Created by Paulo Henrique Costa Alves on 05/11/26.
//

import SwiftUI

/// De onde vem o ícone de uma aba: SF Symbols ou Assets.xcassets.
/// Cada caso guarda o nome do ícone normal e o da aba selecionada.
enum TabBarIcon {
    case system(base: String, selected: String)
    case asset(base: String, selected: String)

    func image(isSelected: Bool) -> Image {
        switch self {
        case let .system(base, selected):
            Image(systemName: isSelected ? selected : base)
        case let .asset(base, selected):
            Image(isSelected ? selected : base)
        }
    }
}

/// Título e ícone de cada aba ficam junto da própria aba.
/// Home, Feelings e Profile são fixos; só Challenges vem do tema.
extension AppTab {
    var title: LocalizedStringKey {
        switch self {
        case .home:       "Home"
        case .challenges: "Challenges"
        case .feelings:   "Feelings"
        case .profile:    "Profile"
        }
    }

    func icon(for style: ThemeStyleProtocol) -> TabBarIcon {
        switch self {
        case .home:       .system(base: "house",     selected: "house.fill")
        case .challenges: style.icons.challengeTab
        case .feelings:   .system(base: "chart.bar", selected: "chart.bar.fill")
        case .profile:    .system(base: "person",    selected: "person.fill")
        }
    }
}
