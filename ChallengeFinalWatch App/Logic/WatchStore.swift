//
//  WatchStore.swift
//  ChallengeFinalWatch Watch App
//
//  Created by Paulo Henrique Costa Alves on 19/11/26.
//

import Foundation

// MARK: - Protocol

/// O que o Presenter enxerga da Store: mudança de step e os dados do desafio.
@MainActor
protocol WatchStoreProtocol: AnyObject {
    func transitionToHome()
    func transitionToDraw()
    func transitionToChallenge()
    func transitionToAccepted()
    func transitionToInProgress()
    func transitionToCompleted()

    // MARK: Desafio (presets)
    func displayChallenge(_ challenge: WatchChallenge)
    func displayAchievement(_ achievement: WatchAchievement)
}

// MARK: - Class

/// Estado do Watch. A View só LÊ daqui; quem escreve é o Presenter.
/// Também repassa as transições de step ao Coordinator.
@MainActor
@Observable
final class WatchStore: WatchStoreProtocol {

    // MARK: - Variables

    /// Coordinator para navegação.
    private let coordinator: WatchRouting

    /// Step atual, vindo do Coordinator. Por ser @Observable, a View
    /// é redesenhada quando ele muda.
    var currentStep: WatchStep {
        coordinator.step
    }

    // MARK: Desafio (presets)

    /// Desafio sorteado. `nil` = ainda não sorteou.
    private(set) var challenge: WatchChallenge?

    /// Conquista do desafio concluído. `nil` = ainda não foi gerada.
    private(set) var achievement: WatchAchievement?

    // MARK: - Init

    init(coordinator: WatchRouting) {
        self.coordinator = coordinator
    }

    // MARK: - Transitions

    func transitionToHome()       { coordinator.goToHome() }
    func transitionToDraw()       { coordinator.goToDraw() }
    func transitionToChallenge()  { coordinator.goToChallenge() }
    func transitionToAccepted()   { coordinator.goToAccepted() }
    func transitionToInProgress() { coordinator.goToInProgress() }
    func transitionToCompleted()  { coordinator.goToCompleted() }

    // MARK: - Desafio (presets)

    func displayChallenge(_ challenge: WatchChallenge) {
        self.challenge = challenge
    }

    func displayAchievement(_ achievement: WatchAchievement) {
        self.achievement = achievement
    }
}
