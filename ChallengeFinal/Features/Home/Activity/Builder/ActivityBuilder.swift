//
//  ActivitiesBuilder.swift
//  ChallengeFinal
//
//  Created by Raquel Souza on 16/10/26.
//

import SwiftUI

enum ActivityBuilder {
    @MainActor
    static func build(coordinator: ActivityCoordinator) -> ActivityView {
        let store = ActivityStore(coordinator: coordinator)
        let presenter = ActivityPresenter(store: store)
        let interactor = ActivityInteractor(presenter: presenter, routing: coordinator)
        return ActivityView(interactor: interactor, store: store)
    }
}
