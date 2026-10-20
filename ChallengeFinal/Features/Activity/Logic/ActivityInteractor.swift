//
//  ChallengesInteractor.swift
//  ChallengeFinal
//
//  Created by Raquel Souza on 19/10/26.
//

import Foundation


@MainActor
final class ActivityInteractor {
    private let presenter: ActivityPresenter
    private weak var routing: ActivityRouting?
    // depois: os Workers chegam aqui pelo init

    init(presenter: ActivityPresenter, routing: ActivityRouting) {
        self.presenter = presenter
        self.routing = routing
    }

    deinit {
        print("ChallengeInteractor liberado")
    }

    func drawChallenge() {
        //CHANGE
        routing?.didDraw()
    }

    func acceptChallenge() {
        routing?.didAcceptChallenge()
    }

    func completeChallenge() {
        //CHANGE
        routing?.didCompleteChallenge()
    }

    func selectMood() {
        //CHANGE
        routing?.didSelectMood()
    }

    func capturePhoto() {
        //CHANGE
        routing?.didCapturePhoto()
    }

    func finish() {
        //CHANGE
        // só avisa o coordinator se salvar com sucesso
        routing?.didFinishChallenge()
    }
}
