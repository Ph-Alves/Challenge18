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
    
    ///Icone que aparece na tela de perfil na seção STREAK CARD
    var streakIcon: String {
        switch self {
        case .sober: return SoberStyle().icons.activityIcons[.physical]?.closed ?? "eightBall"
        case .pop: return SoberStyle().icons.activityIcons[.physical]?.closed ?? "eightBall" //CHANGE: trocar por PopStyle() quando existir.
        case .bubblegum: return SoberStyle().icons.activityIcons[.physical]?.closed ?? "eightBall" //CHANGE: trocar por BubblegumStyle() quando existir.
        case .techNature: return SoberStyle().icons.activityIcons[.physical]?.closed ?? "eightBall" //CHANGE: trocar por TechNatureStyle() quando existir.
        }
    }
    
    ///Icone que aparece na tela de perfil na seção de TEMAS
    var previewIcon: String {
        switch self {
        case .sober: return SoberStyle().icons.activityIcons[.physical]?.closed ?? "eightBall"
        case .pop: return "popThemeIcon" //CHANGE: colocar asset real.
        case .bubblegum: return "bubblegumThemeIcon" //CHANGE: colocar asset real.
        case .techNature: return "techNatureThemeIcon" //CHANGE: colocar asset real.
        }
    }
}
