//
//  ActivityStore.swift
//  ChallengeFinal
//
//  Created by Paulo Henrique Costa Alves on 23/10/26.
//

import Foundation
import SwiftData

protocol ActivityStoreProtocol: AnyObject {
    func displayCurrentStep() -> ActivityStep
    func displayActivityFinished()
    func displayChallenge(_ challenge: FrictionChallenge)
}

@MainActor
@Observable
final class ActivityStore: ActivityStoreProtocol {
    private let coordinator: ActivityRouting
    private(set) var activityTitle: String?
    private(set) var activitySubtitle: String?
    private(set) var activityDescription: String?
    
    init(coordinator: ActivityRouting) {
        self.coordinator = coordinator
    }
    
    func displayCurrentStep() -> ActivityStep {
        return self.coordinator.step
    }
    
    func displayChallenge(_ challenge: FrictionChallenge) {
        self.coordinator.didDraw()
        self.activityTitle = challenge.title
        self.activitySubtitle = challenge.subTitle
        self.activityDescription = challenge.rationale
    }
    
    func displayActivityFinished() {
        self.coordinator.didFinishChallenge()
    }
}
