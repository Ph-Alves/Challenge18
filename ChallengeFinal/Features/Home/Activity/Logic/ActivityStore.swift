//
//  ActivityStore.swift
//  ChallengeFinal
//
//  Created by Paulo Henrique Costa Alves on 23/10/26.
//

import Foundation
import SwiftData

protocol ActivityStoreProtocol: AnyObject {
    func finishFlow()
    func displayChallenge(_ challenge: FrictionChallenge)
    func displaySearching()
    func displaySearchFailed()
    func displayAcceptedChallenge()
    func transitionToAcceptedChallenge()
    func transitionToStart()
    func transitionToChallenge()
}

@MainActor
@Observable
final class ActivityStore: ActivityStoreProtocol {
    
    private let coordinator: ActivityRouting
    var currentStep: ActivityStep {
        return self.coordinator.step
    }
    private(set) var activityTitle: String?
    private(set) var activitySubtitle: String?
    private(set) var activityDescription: String?
    private(set) var isSearching = false
    private(set) var isChallengeReady = false
    private(set) var isChallengeAccepted = false

    init(coordinator: ActivityRouting) {
        self.coordinator = coordinator
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
    
    func displayAcceptedChallenge() {
        self.isChallengeAccepted = true
    }
    
    func transitionToAcceptedChallenge() {
        self.coordinator.didAcceptChallenge()
    }
    
    func transitionToStart() {
        // Limpa o estado do sorteio para permitir gerar um novo desafio
        self.isSearching = false
        self.isChallengeReady = false
        self.isChallengeAccepted = false
        self.coordinator.didReturn()
    }

    func transitionToChallenge() {
        self.coordinator.didDraw()
    }
    
    func finishFlow() {
        self.coordinator.didFinishChallenge()
    }
}
