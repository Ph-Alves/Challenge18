//
//  ChallengesInteractor.swift
//  ChallengeFinal
//
//  Created by Raquel Souza on 19/10/26.
//

import Foundation
import FoundationModels


protocol ActivityInteractorProtocol: AnyObject {
    func acceptChallenge()
    func startChallenge()
    func goToActivityDetail()
    func returnToStart()
    func finishActivity()
}


@MainActor
final class ActivityInteractor: ActivityInteractorProtocol {
    
    private let presenter: ActivityPresenterProtocol
    private let activityRepository: GenericRepository<Activity>
    private var hapticWorker: HapticsWorkerProtocol
    private var coreMotionWorker: CoreMotionWorkerProtocol
    private var foundationWorker: FoundationWorkerProtocol
    
    private var shakeWasStrongEnough = false
    private var shakeIdleTimer: Timer?
    private let motionFeedbackThreshold: Double = 0.3
    private var isRaffling: Bool = false
    
    init(presenter: ActivityPresenter, activityRepository: GenericRepository<Activity>, hapticWorker: HapticsWorkerProtocol, coreMotionWorker: CoreMotionWorkerProtocol, foundationWorker: FoundationWorkerProtocol) {
        self.presenter = presenter
        self.activityRepository = activityRepository
        self.hapticWorker = hapticWorker
        self.coreMotionWorker = coreMotionWorker
        self.foundationWorker = foundationWorker
    }
    
    //
    func acceptChallenge() {
        presenter.presentAcceptedActivity()
    }
    
    func startChallenge() {
        presenter.presentStartedChallenge()
    }
    
    func goToActivityDetail() {
        presenter.presentActivityDetail()
    }
    
    func returnToStart() {
        presenter.presentStartAgain()
    }
    
    func finishActivity() {
        presenter.presentActivityFinished()
    }
}
