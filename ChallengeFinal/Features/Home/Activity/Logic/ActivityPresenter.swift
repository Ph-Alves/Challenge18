//
//  ChallengePresenter.swift
//  ChallengeFinal
//
//  Created by Raquel Souza on 19/10/26.
//

import Foundation

protocol ActivityPresenterProtocol: AnyObject {
    func presentActivityFinished()
    func presentStartedChallenge()
    func presentActivityDetail()
    func presentStartAgain()
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
    
    func presentStartedChallenge() {
        store?.transitionToAcceptedChallenge()
    }
    
    func presentActivityDetail() {
        store?.transitionToChallenge()
    }
    
    func presentStartAgain() {
        store?.transitionToStart()
    }
}
