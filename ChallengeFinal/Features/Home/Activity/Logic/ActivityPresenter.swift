//
//  ChallengePresenter.swift
//  ChallengeFinal
//
//  Created by Raquel Souza on 19/10/26.
//

import Foundation

protocol ActivityPresenterProtocol: AnyObject {
    
}

@MainActor
final class ActivityPresenter: ActivityPresenterProtocol {
    weak var store: ActivityStoreProtocol?
    
    init(store: ActivityStoreProtocol) {
        self.store = store
    }
}
