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
    case sensorial
    case social
    
    var closedIcon: String {
        DesignSystem.shared.style.icons.activityIcons[self]?.closed ?? ""
    }

    var openIcon: String {
        DesignSystem.shared.style.icons.activityIcons[self]?.open ?? ""
    }

    var cardIcon: String {
        DesignSystem.shared.style.icons.activityIcons[self]?.card ?? ""
    }
    
    var description: String {
        switch self {
        case .physical:
            return "desafios que colocam seu corpo para se mexer"
        case .cognitive:
            return "desafios que fazem você pensar por conta própria"
        case .sensorial:
            return "desafios que diminuem os estímulos do seu dia"
        case .social:
            return "desafios que te aproximam das pessoas"

        }
    }

    var text: String {
        switch self {
        case .cognitive:
            return "mente"
        case .physical:
            return "movimento"
        case .sensorial:
            return "sentidos"
        case .social:
            return "conexão"
        }
    }
}
