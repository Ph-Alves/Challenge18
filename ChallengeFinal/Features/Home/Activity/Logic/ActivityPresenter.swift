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
    func presentAcceptedActivity()
    func presentStartedChallenge()
    func presentActivityDetail()
    func presentStartAgain()
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
        store?.finishFlow()
    }
    
    func presentAcceptedActivity() {
        store?.displayAcceptedChallenge()
    }
    
    func presentStartedChallenge() {
        store?.transitionToAcceptedChallenge()
    }
    
    func presentActivityDetail() {
        store?.transitionToChallenge()
    }
    
    func presentStartAgain() {
        store?.transitionToStart()
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
