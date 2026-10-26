//
//  ActivitiesCoordinator.swift
//  ChallengeFinal
//
//  Created by Raquel Souza on 19/10/26.
//

import Foundation
import SwiftUI

enum ActivityStep {
    case draw, challenge, inProgress, mood, photo, summary
}


@MainActor
@Observable
final class ActivityCoordinator: Identifiable {
    private(set) var step: ActivityStep = .draw
    private let onFinish: () -> Void

    init(onFinish: @escaping () -> Void) {
        self.onFinish = onFinish
    }

    deinit {
        print("ChallengeCoordinator liberado")
    }
    
    //MARK: EXCLUIR ESSA FUNÇÃO APÓS IMPLEMENTAÇÃO DO INTERACTOR. Deixei ela aqui só pro app rodar.
    func debugNext() {
        switch step {
        case .draw:
            step = .challenge
        case .challenge:
            step = .inProgress
        case .inProgress:
            step = .mood
        case .mood:
            step = .photo
        case .photo:
            
            step = .summary
        case .summary:
            onFinish()
        }
    }
}

extension ActivityCoordinator: ActivityRouting {
    func didDraw()              { step = .challenge }
    func didAcceptChallenge()   { step = .inProgress }
    func didCompleteChallenge() { step = .mood }
    func didSelectMood()        { step = .photo }
    func didCapturePhoto()      { step = .summary }
    func didFinishChallenge()   { onFinish() }
}
