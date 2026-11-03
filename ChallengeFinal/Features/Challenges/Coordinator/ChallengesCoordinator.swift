//
//  ChallengesCoordinator.swift
//  ChallengeFinal
//
//  Created by Raquel Souza on 03/11/26.
//

/*
 /// Etapas do fluxo de Activity, em ordem:
 /// sortear -> ver desafio -> em andamento -> humor -> foto -> resumo.
 enum ActivityStep {
     case draw, challenge, inProgress, mood, photo, summary
 }
 */

import SwiftUI
import SwiftData

// MARK: - Enum
// Telas que podem ser empilhadas sobre a listagem de desafios.
// Os arquivados não estão aqui porque são um sheet (controlado pela Store)
enum ChallengesRoute: Hashable {
    case summary
}


@MainActor
@Observable
final class ChallengesCoordinator: ChallengesRouting {
    
    // Não é `private(set)` porque o NavigationStack precisa de binding:
    // o gesto/botão de voltar do sistema remove o último item sozinho.
    var path: [ChallengesRoute] = []

    // Mesmo motivo da Home: a view não deve ser recriada a cada render.
    @ObservationIgnored var cached: ChallengesView?

    func startChallengesFlow(context: ModelContext) -> ChallengesView {
        if let cached {
            return cached
        }

        let view = ChallengesBuilder.build(routing: self, context: context)
        cached = view
        return view
    }

//    func showSummary(_ summary: ChallengeSummaryViewModel) {
//        path.append(.summary(summary))
//    }

    func popToList() {
        path.removeAll()
    }
}
