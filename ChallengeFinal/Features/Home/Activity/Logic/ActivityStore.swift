//
//  ActivityStore.swift
//  ChallengeFinal
//
//  Created by Paulo Henrique Costa Alves on 23/10/26.
//

import Foundation
import SwiftData

protocol ActivityStoreProtocol: AnyObject {
    func transitionToAcceptedChallenge()
    func transitionToStart()
    func transitionToChallenge()
    func finishFlow()
}

@MainActor
@Observable
final class ActivityStore: ActivityStoreProtocol {
    
    private let coordinator: ActivityRouting
    var currentStep: ActivityStep {
        return self.coordinator.step
    }

    init(coordinator: ActivityRouting) {
        self.coordinator = coordinator
    }
    
    func transitionToAcceptedChallenge() {
        self.coordinator.didAcceptChallenge()
    }
    
    func transitionToStart() {
        self.coordinator.didReturn()
    }

    func transitionToChallenge() {
        self.coordinator.didDraw()
    }
    
    func finishFlow() {
        self.coordinator.didFinishChallenge()
    }
}
