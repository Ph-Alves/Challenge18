//
//  ActivitiesCoordinator.swift
//  ChallengeFinal
//
//  Created by Raquel Souza on 19/10/26.
//

import Foundation
import SwiftUI
import SwiftData

enum ActivityStep {
    case draw, challenge, inProgress, mood, photo, summary
}

@MainActor
@Observable
final class ActivityCoordinator {
    private(set) var step: ActivityStep = .draw
    private let selectedCategory: ActivityCategory
    private let onFinish: () -> Void
    
    var cached: ActivityView?

    init(selectedCategory: ActivityCategory, onFinish: @escaping () -> Void) {
        self.selectedCategory = selectedCategory
        self.onFinish = onFinish
    }
    
    func startActivityView(context: ModelContext) -> ActivityView {
        if let cached = cached {
            return cached
        }
        
        let view = ActivityBuilder.build(coordinator: self, context: context, currentCategory: selectedCategory)
        cached = view
        return view
    }
}

extension ActivityCoordinator: ActivityRouting {
    func didReturn()            { step = .draw }
    func didDraw()              { step = .challenge }
    func didAcceptChallenge()   { step = .inProgress }
    func didCompleteChallenge() { step = .mood }
    func didSelectMood()        { step = .photo }
    func didCapturePhoto()      { step = .summary }
    func didFinishChallenge()   { onFinish() }
}
