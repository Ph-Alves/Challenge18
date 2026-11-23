//
//  WatchChallenge.swift
//  ChallengeFinalWatch Watch App
//
//  Created by Paulo Henrique Costa Alves on 23/11/26.
//

import Foundation

/// Um desafio pronto para ser mostrado na tela.
/// Equivale ao `FrictionChallenge` do iOS, mas sem `@Generable`: no Watch ele só vem dos presets.
struct WatchChallenge: Equatable, Sendable {
    /// Frase do círculo.
    let title: String
    /// Nome curto do desafio.
    let subTitle: String
    /// Descrição do que fazer.
    let rationale: String
}

/// Conquista mostrada quando o desafio termina.
/// Equivale ao `Achievement` do iOS.
struct WatchAchievement: Equatable, Sendable {
    let title: String
    let description: String
}
