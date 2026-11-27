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
    func displayCategory(_ category: WatchCategory)
    func displayChallenge(_ challenge: WatchChallenge)
    func displayAchievement(_ achievement: WatchAchievement)

    // MARK: Cronômetro
    func displayTimer(_ text: String)
    func displayPaused(_ isPaused: Bool)
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

    /// Categoria escolhida na home. As telas do fluxo (e o "outro desafio") partem dela.
    private(set) var category: WatchCategory = .physical

    /// Desafio sorteado. `nil` = ainda não sorteou.
    private(set) var challenge: WatchChallenge?

    /// Conquista do desafio concluído. `nil` = ainda não foi gerada.
    private(set) var achievement: WatchAchievement?

    // MARK: Cronômetro

    /// Tempo do cronômetro já formatado ("hh:mm:ss").
    /// O Presenter escreve a cada tick; a View só lê.
    private(set) var timeText: String = "00:00:00"

    /// O cronômetro está pausado (a View troca o ícone de pausar por tocar).
    private(set) var isPaused = false

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

    func displayCategory(_ category: WatchCategory) {
        self.category = category
    }

    func displayChallenge(_ challenge: WatchChallenge) {
        self.challenge = challenge
    }

    func displayAchievement(_ achievement: WatchAchievement) {
        self.achievement = achievement
    }

    // MARK: - Cronômetro

    func displayTimer(_ text: String) {
        timeText = text
    }

    func displayPaused(_ isPaused: Bool) {
        self.isPaused = isPaused
    }
}
