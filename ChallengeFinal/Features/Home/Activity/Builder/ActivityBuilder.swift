//
//  ActivitiesBuilder.swift
//  ChallengeFinal
//
//  Created by Raquel Souza on 16/10/26.
//

import SwiftUI
import SwiftData

enum ActivityBuilder {
    @MainActor
    static func build(coordinator: ActivityCoordinator, context: ModelContext, currentCategory: ActivityCategory) -> ActivityView {
        let store = ActivityStore(coordinator: coordinator)
        let presenter = ActivityPresenter(store: store)
        let interactor = ActivityInteractor(presenter: presenter, activityRepository: GenericRepository<Activity>(context: context),hapticWorker: HapticsWorker(), coreMotionWorker: CoreMotionWorker(), foundationWorker: FoundationWorker())
        return ActivityView(interactor: interactor, currentCategory: currentCategory, store: store)
    }
}
