//
//  ChallengesRouting.swift
//  ChallengeFinal
//
//  Created by Raquel Souza on 03/11/26.
//

import SwiftUI
import SwiftData


// MARK: - Protocol
// O que a Store enxerga do Coordinator: só navegação.
// Com o protocolo, nos testes dá para trocar por um fake que só anota as chamadas.
@MainActor
protocol ChallengesRouting: AnyObject {
    // View já montada (evita recriar a lista a cada render da TabView)
    var cached: ChallengesView? { get set }

    // Monta (ou devolve do cache) a view da listagem
    func startChallengesFlow(context: ModelContext) -> ChallengesView
}

