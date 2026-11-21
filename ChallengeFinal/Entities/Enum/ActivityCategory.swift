//
//  GroupType.swift
//  ChallengeFinal
//
//  Created by Raquel Souza on 16/10/26.
//

// MARK: - Tipo de grupo
enum ActivityCategory: String, Codable, CaseIterable {
    case physical
    case cognitive
    case social
    case sensorial
    
    var closedIcon: String {
        DesignSystem.shared.style.icons.activityIcons[self]?.closed ?? ""
    }

    var openIcon: String {
        DesignSystem.shared.style.icons.activityIcons[self]?.open ?? ""
    }

    var cardIcon: String {
        DesignSystem.shared.style.icons.activityIcons[self]?.card ?? ""
    }

    var text: String {
        switch self {
        case .physical:
            return "movimento"
        case .cognitive:
            return "mente"
        case .social:
            return "conexões"
        case .sensorial:
            return "sensorial"
        }
    }
}
