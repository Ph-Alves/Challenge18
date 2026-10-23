//
//  ChallengesInteractor.swift
//  ChallengeFinal
//
//  Created by Raquel Souza on 19/10/26.
//

import Foundation


protocol ActivityInteractorProtocol: AnyObject {
    func finishActivity()
}


@MainActor
final class ActivityInteractor: ActivityInteractorProtocol {
    private let presenter: ActivityPresenterProtocol

    init(presenter: ActivityPresenter, routing: ActivityRouting) {
        self.presenter = presenter
    }
    
    func finishActivity() {
        presenter.presentActivityFinished()
    }
}
