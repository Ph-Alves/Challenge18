//
//  Humor.swift
//  ChallengeFinal
//
//  Created by Raquel Souza on 16/10/26.
//

// MARK: - Tipo de humor do usuário ao realizar uma atividade
enum Humor: String, Codable, CaseIterable { //CaseIterable: a roleta monta as opções na ordem em que os cases foram declarados.
    case veryPleasant = "Ótimo"
    case pleasant = "Agradável"
    case neutral = "Neutro"
    case unpleasant = "Desagradável"
    case veryUnpleasant = "Péssimo"


    
    // Vêm do tema ativo (sem valor próprio no enum)
    var icon: String {
        DesignSystem.shared.style.icons.feelingIcons[self]?.humor ?? ""
    }

    var baseIcon: String {
        DesignSystem.shared.style.icons.feelingIcons[self]?.base ?? ""
    }
    
    var cardIcon: String { DesignSystem.shared.style.icons.feelingIcons[self]?.card ?? ""
    }
    
    var whiteIcon: String {
        DesignSystem.shared.style.icons.feelingIcons[self]?.white ?? ""
    }
    
}

extension Humor {
    func moved(by offset: Int) -> Humor {
        let all = Humor.allCases
        let index = all.firstIndex(of: self) ?? 0
        return all[(index + offset + all.count) % all.count]
    }
}
