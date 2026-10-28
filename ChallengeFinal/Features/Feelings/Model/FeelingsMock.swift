//
//  FeelingsMock.swift
//  ChallengeFinal
//
//  Modelos e dados mockados da tela de sentimentos.
//

import SwiftUI

struct FeelingEmotion: Identifiable, Hashable {
    let id = UUID()
    let humor: Humor
    let count: Int

    var name: String { humor.rawValue.lowercased() }
    /// Nome do asset de humor no catálogo.
    var asset: String { humor.icon }
}

struct FeelingGroup: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let symbol: String
    let count: Int
    /// Proporção de cada segmento empilhado na barra (do topo para a base).
    let segments: [Double]
    let shade: Double

    var color: Color { Color(white: 0.1 + 0.55 * shade) }
}

struct FeelingChallenge: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let category: String
    let date: String
    let categorySymbol: String
    let emotionAsset: String
}

enum FeelingsDestination: Hashable {
    case emotion(FeelingEmotion)
    case group(FeelingGroup)
}

enum FeelingsMock {
    static let emotions: [FeelingEmotion] = [
        .init(humor: .chill, count: 2),
        .init(humor: .calm, count: 3),
        .init(humor: .annoyed, count: 4),
        .init(humor: .locked, count: 1),
        .init(humor: .frustrated, count: 4)
    ]

    static let groups: [FeelingGroup] = [
        .init(name: "exercícios físicos", symbol: "dumbbell.fill", count: 4, segments: [0.25, 0.35, 0.4], shade: 0.0),
        .init(name: "mente", symbol: "brain.head.profile", count: 2, segments: [1], shade: 0.4),
        .init(name: "alimentação", symbol: "fork.knife", count: 2, segments: [1], shade: 0.7),
        .init(name: "social", symbol: "bubble.left.and.bubble.right.fill", count: 2, segments: [1], shade: 1.0)
    ]

    static func challenges(for emotion: FeelingEmotion) -> [FeelingChallenge] {
        groups.prefix(3).map {
            FeelingChallenge(
                title: "Título do desafio",
                category: $0.name,
                date: "DD/MM/AA",
                categorySymbol: $0.symbol,
                emotionAsset: emotion.asset
            )
        }
    }

    static func challenges(for group: FeelingGroup) -> [FeelingChallenge] {
        (0..<4).map { index in
            FeelingChallenge(
                title: "Título do desafio",
                category: group.name,
                date: "DD/MM/AA",
                categorySymbol: group.symbol,
                emotionAsset: emotions[index % emotions.count].asset
            )
        }
    }
}
