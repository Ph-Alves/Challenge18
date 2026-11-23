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

    /// Categoria `offset` posições à frente (ou atrás, se negativo), voltando ao início nas pontas.
    /// Segue a ordem dos cases, a mesma do swipe da Home.
    func shifted(by offset: Int) -> ActivityCategory {
        let all = ActivityCategory.allCases
        let index = all.firstIndex(of: self) ?? 0
        return all[((index + offset) % all.count + all.count) % all.count]
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
