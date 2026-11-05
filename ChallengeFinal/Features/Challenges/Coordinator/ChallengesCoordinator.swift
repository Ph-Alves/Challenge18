//
//  ChallengesCoordinator.swift
//  ChallengeFinal
//
//  Created by Raquel Souza on 03/11/26.
//


import SwiftUI
import SwiftData

//MARK: - Class
@MainActor
final class ChallengesCoordinator: ChallengesRouting {
 
    /// Cache da view para não reconstruir a cena a cada render da TabView.
    var cached: ChallengesView?
    
    init(cached: ChallengesView? = nil) {
        self.cached = cached
    }

    func startChallengesFlow(context: ModelContext) -> ChallengesView {
        if let cached {
            return cached
        }

        let view = ChallengesBuilder.build(context: context)
        cached = view
        return view
    }
}

