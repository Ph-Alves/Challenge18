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
}

@MainActor
@Observable
final class ActivityStore: ActivityStoreProtocol {
    let coordinator: ActivityRouting
    
    init(coordinator: ActivityRouting) {
        self.coordinator = coordinator
    }
    
    func displayCurrentStep() -> ActivityStep {
        return self.coordinator.step
    }
    
    func displayActivityFinished() {
        self.coordinator.didFinishChallenge()
    }
}
