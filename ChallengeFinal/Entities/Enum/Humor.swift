//
//  Humor.swift
//  ChallengeFinal
//
//  Created by Raquel Souza on 16/10/26.
//

// MARK: - Tipo de humor do usuário ao realizar uma atividade
enum Humor: String, Codable, CaseIterable { //CaseIterable: a roleta monta as opções na ordem em que os cases foram declarados.
    case veryUnpleasant = "Péssimo"
    case unpleasant = "Desagradável"
    case neutral = "Neutro"
    case pleasant = "Agradável"
    case veryPleasant = "Ótimo"
    
    // Vêm do tema ativo (sem valor próprio no enum)
    var icon: String {
        DesignSystem.shared.style.icons.feelingIcons[self]?.humor ?? ""
    }

    var baseIcon: String {
        DesignSystem.shared.style.icons.feelingIcons[self]?.base ?? ""
    }
}


extension Humor {
    func moved(by offset: Int) -> Humor {
        let all = Humor.allCases
        let index = all.firstIndex(of: self) ?? 0
        return all[(index + offset + all.count) % all.count]
    }
}
