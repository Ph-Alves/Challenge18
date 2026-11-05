//
//  Theme.swift
//  ChallengeFinal
//
//  Created by Raquel Souza on 16/10/26.
//

// MARK: - Enum de temas
enum Theme: String, Codable {
    case sober
    case bubblegum
    case pop
    case techNature
    
    var displayName: String {
        switch self {
        case .sober: return "sober."
        case .bubblegum: return "bubblegum"
        case .pop: return "pop!"
        case .techNature: return "tech nature"
        }
    }
}
