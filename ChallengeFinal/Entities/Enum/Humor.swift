//
//  Humor.swift
//  ChallengeFinal
//
//  Created by Raquel Souza on 16/10/26.
//

// MARK: - Tipo de humor do usuário ao realizar uma atividade
enum Humor: String, Codable {
    case frustrated = "Frustrado"
    case locked = "Travado"
    case annoyed = "Incomodado"
    case calm = "Leve"
    case chill = "Tranquilo"
    
    var icon: String {
        switch self {
        case .frustrated:
            return "frustrado"
        case .locked:
            return "travado"
        case .annoyed:
            return "incomodado"
        case .calm:
            return "tranquilo"
        case .chill:
            return "leve"
        }
    }
}
