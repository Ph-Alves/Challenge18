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
    
    var icon: String {
        switch self {
        case .cognitive:
            return "brain.fill"
        case .physical:
            return "dumbbell.fill"
        case .sensorial:
            return "hand.raised.fill"
        case .social:
            return "person.fill"
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
