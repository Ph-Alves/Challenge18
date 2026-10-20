//
//  ActivitiesBuilder.swift
//  ChallengeFinal
//
//  Created by Raquel Souza on 16/10/26.
//

import SwiftUI

enum ChallengesBuilder {
    @MainActor
    static func build(coordinator: ChallengesCoordinator) -> some View {
        let presenter = ChallengePresenter()
        let interactor = ChallengeInteractor(presenter: presenter, routing: coordinator)
        return ChallengeView(coordinator: coordinator, interactor: interactor)
    }
}
