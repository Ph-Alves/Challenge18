//
//  ChallengePresenter.swift
//  ChallengeFinal
//
//  Created by Raquel Souza on 19/10/26.
//

import Foundation

protocol ActivityPresenterProtocol: AnyObject {
    func presentActivityFinished()
    func presentChallenge(_ challenge: FrictionChallenge)
    func presentSearching()
    func presentSearchFailed()
}

@MainActor
final class ActivityPresenter: ActivityPresenterProtocol {
    private weak var store: ActivityStoreProtocol?
    
    init(store: ActivityStoreProtocol) {
        self.store = store
    }
    
    func presentActivityFinished() {
        store?.displayActivityFinished()
    }
    
    func presentChallenge(_ challenge: FrictionChallenge) {
        store?.displayChallenge(challenge)
    }

    func presentSearching() {
        store?.displaySearching()
    }

    func presentSearchFailed() {
        store?.displaySearchFailed()
    }
}
