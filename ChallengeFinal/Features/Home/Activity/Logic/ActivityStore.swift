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
    func displaySearching()
    func displaySearchFailed()
    func transitionToChallenge()
}

@MainActor
@Observable
final class ActivityStore: ActivityStoreProtocol {
    private let coordinator: ActivityRouting
    private(set) var activityTitle: String?
    private(set) var activitySubtitle: String?
    private(set) var activityDescription: String?
    private(set) var isSearching = false
    private(set) var isChallengeReady = false

    init(coordinator: ActivityRouting) {
        self.coordinator = coordinator
    }
    
    func displayCurrentStep() -> ActivityStep {
        return self.coordinator.step
    }
    
    func displayChallenge(_ challenge: FrictionChallenge) {
        self.activityTitle = challenge.title
        self.activitySubtitle = challenge.subTitle
        self.activityDescription = challenge.rationale
        self.isSearching = false
        // A view anima a bola e só depois chama transitionToChallenge()
        self.isChallengeReady = true
    }

    func displaySearching() {
        self.isSearching = true
    }

    func displaySearchFailed() {
        self.isSearching = false
    }

    func transitionToChallenge() {
        self.coordinator.didDraw()
    }
    
    func displayActivityFinished() {
        self.coordinator.didFinishChallenge()
    }
}
