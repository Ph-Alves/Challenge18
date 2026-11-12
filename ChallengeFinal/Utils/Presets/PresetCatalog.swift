//
//  PresetCatalog.swift
//  ChallengeFinal
//
//  Created by Paulo Henrique Costa Alves on 12/11/26.
//

import Foundation

/// Conquista pré-pronta, mostrada quando a pessoa conclui o desafio.
struct PresetAchievement: Hashable, Sendable {
    /// Trecho da descrição que vira o tempo do cronômetro (ex.: "1h 20 min") quando a conquista é mostrada.
    static let durationPlaceholder = "{tempo}"

    /// Título da conquista (limite de 16 caracteres).
    let title: String
    /// Descrição da conquista (o "story"), com `durationPlaceholder` no lugar do tempo.
    let description: String

    /// Descrição com o tempo recebido no lugar do `durationPlaceholder`.
    func description(duration: String) -> String {
        description.replacingOccurrences(of: Self.durationPlaceholder, with: duration)
    }
}

/// Desafio pré-pronto, escrito à mão, junto com a conquista dele.
/// `title` é a frase do círculo (limite de 42 caracteres), `subTitle` é o nome curto e `rationale` é a descrição.
struct PresetChallenge: Hashable, Sendable {
    let title: String
    let subTitle: String
    let rationale: String
    let achievement: PresetAchievement
}

/// Desafios pré-prontos de cada categoria.
enum PresetCatalog {
    static func challenges(for category: ActivityCategory) -> [PresetChallenge] {
        switch category {
        case .physical: return movement
        case .sensorial: return senses
        case .cognitive: return mind
        case .social: return connection
        }
    }
}
