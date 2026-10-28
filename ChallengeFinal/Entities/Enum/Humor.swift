//
//  Humor.swift
//  ChallengeFinal
//
//  Created by Raquel Souza on 16/10/26.
//

// MARK: - Tipo de humor do usuário ao realizar uma atividade
enum Humor: String, Codable, CaseIterable { //CaseIterable: a roleta monta as opções na ordem em que os cases foram declarados.
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
    
    /// Frase curta mostrada embaixo do nome, na roleta.
    /// CHANGE: checar frases com o paulinho.
    var detail: String {
        switch self {
        case .frustrated:
            return "foi difícil e irritante"
        case .locked:
            return "não consegui sair do lugar"
        case .annoyed:
            return "algo me incomodou"
        case .calm:
            return "fluiu sem esforço"
        case .chill:
            return "me senti em paz"
        }
    }
}
