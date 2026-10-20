//
//  ActivitiesBuilder.swift
//  ChallengeFinal
//
//  Created by Raquel Souza on 16/10/26.
//

import SwiftUI

enum ActivityBuilder {
    @MainActor
    static func build(coordinator: ActivityCoordinator) -> some View {
        let presenter = ActivityPresenter()
        let interactor = ActivityInteractor(presenter: presenter, routing: coordinator)
        return ActivityView(coordinator: coordinator, interactor: interactor)
    }
}
