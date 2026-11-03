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
@Observable
final class ChallengesCoordinator: ChallengesRouting {

    //a view não deve ser recriada a cada render.
    @ObservationIgnored var cached: ChallengesView?

    func startChallengesFlow(context: ModelContext) -> ChallengesView {
        if let cached {
            return cached
        }

        let view = ChallengesBuilder.build(routing: self, context: context)
        cached = view
        return view
    }
}
