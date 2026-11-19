//
//  WatchRouting.swift
//  ChallengeFinalWatch Watch App
//
//  Created by Paulo Henrique Costa Alves on 19/11/26.
//

import Foundation

/// O que a Store enxerga do Coordinator: em qual step estamos e como trocar de step.
@MainActor
protocol WatchRouting: AnyObject {
    var step: WatchStep { get }

    func goToHome()
    func goToDraw()
    func goToChallenge()
    func goToAccepted()
    func goToInProgress()
    func goToCompleted()
}
