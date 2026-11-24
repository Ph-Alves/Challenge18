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
    
    //usado no carrosel da home apenas
    var homeCarousel: String {
        DesignSystem.shared.style.icons.activityIcons[self]?.homeCarousel ?? ""
    }
    
    //icone padrao fechado
    var defaultClosed: String {
        DesignSystem.shared.style.icons.activityIcons[self]?.defaultClosed ?? ""
    }
    
    //icone padrao aberto
    var defaultOpen: String {
        DesignSystem.shared.style.icons.activityIcons[self]?.defaultOpen ?? ""
    }
    
    //icone usado na tela 'durante desafio' do activityFlow, o step 'display'
    var activityFlowCard: String {
        DesignSystem.shared.style.icons.activityIcons[self]?.activityFlowCard ?? ""
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
        case .cognitive:
            return "mente"
        case .physical:
            return "movimento"
        case .sensorial:
            return "sensorial"
        case .social:
            return "conexão"
        }
    }
}
