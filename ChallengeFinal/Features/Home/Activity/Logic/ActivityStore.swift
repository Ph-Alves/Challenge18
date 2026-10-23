//
//  ActivityStore.swift
//  ChallengeFinal
//
//  Created by Paulo Henrique Costa Alves on 23/10/26.
//

import Foundation
import SwiftData

protocol ActivityStoreProtocol: AnyObject {
    func getCurrentStep() -> ActivityStep
}

@MainActor
@Observable
final class ActivityStore: ActivityStoreProtocol {
    let coordinator: ActivityRouting
    
    init(coordinator: ActivityRouting) {
        self.coordinator = coordinator
    }
    
    func getCurrentStep() -> ActivityStep {
        return coordinator.step
    }
}
