//
//  Theme.swift
//  ChallengeFinal
//
//  Created by Raquel Souza on 16/10/26.
//

// MARK: - Enum de temas
enum Theme: String, Codable {
    case sober
    case pop
    case techNature
    
    var displayName: String {
        switch self {
        case .sober: return "sober."
        case .pop: return "pop!"
        case .techNature: return "tech nature"
        }
    }
    
    ///Icone que aparece na tela de perfil na seção STREAK CARD
    var streakIcon: String {
        switch self {
        case .sober: return SoberStyle().icons.activityIcons[.physical]?.defaultClosed ?? "eightBall"
        case .pop: return PopStyle().icons.activityIcons[.social]?.defaultClosed ?? "tomato"
        case .techNature: return TechNatureStyle().icons.activityIcons[.cognitive]?.defaultClosed ?? "techCognitive"
        }
    }
    
    ///Icone que aparece na tela de perfil na seção de TEMAS
    var previewIcon: String {
        switch self {
        case .sober: return SoberStyle().icons.activityIcons[.physical]?.defaultClosed ?? "eightBall"
        case .pop: return PopStyle().icons.activityIcons[.cognitive]?.defaultClosed ?? "popDice"
        case .techNature: return TechNatureStyle().icons.activityIcons[.cognitive]?.defaultClosed ?? "techCognitive"
        }
    }
}
