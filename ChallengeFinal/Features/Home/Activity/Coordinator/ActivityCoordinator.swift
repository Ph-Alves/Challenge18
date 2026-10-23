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
final class ActivityCoordinator {
    private(set) var step: ActivityStep = .draw
    private let onFinish: () -> Void
    
    var cached: ActivityView?

    init(onFinish: @escaping () -> Void) {
        self.onFinish = onFinish
    }
    
    func startActivityView() -> ActivityView {
        if let cached = cached {
            return cached
        }
        
        let view = ActivityBuilder.build(coordinator: self)
        cached = view
        return view
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
