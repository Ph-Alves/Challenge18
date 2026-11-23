//
//  WatchPresenter.swift
//  ChallengeFinalWatch Watch App
//
//  Created by Paulo Henrique Costa Alves on 19/11/26.
//

import Foundation

// MARK: - Protocol

/// O que o Interactor enxerga do Presenter.
///
/// Com o protocolo, nos testes do Interactor dá para usar um *spy*
/// (um Presenter falso que só anota o que foi chamado), sem Store nem View.
@MainActor
protocol WatchPresenterProtocol: AnyObject {
    // MARK: Navigation
    func presentHome()
    func presentDraw()
    func presentChallenge()
    func presentAccepted()
    func presentInProgress()
    func presentCompleted()

    // MARK: Desafio (presets)
    func presentCategory(_ category: WatchCategory)
    func presentDrawnChallenge(_ challenge: WatchChallenge)
    func presentAchievement(_ achievement: WatchAchievement)

    // MARK: Cronômetro
    func presentTime(_ elapsed: TimeInterval)
    func presentPaused(_ isPaused: Bool)
}

// MARK: - Class

/// O "tradutor" do Watch.
///
/// Por enquanto só traduz "apresentar X" em "transicionar para X" na Store.
///
/// Regras:
/// - Não chama Interactor, Worker nem Coordinator.
/// - Não decide regra de negócio (isso é do Interactor), só COMO mostrar.
/// - Só conhece a Store pelo `WatchStoreProtocol`.
@MainActor
final class WatchPresenter: WatchPresenterProtocol {

    // MARK: - Variables

    /// Fraca para não criar ciclo com a Store.
    weak var store: WatchStoreProtocol?

    // MARK: - Init

    init(store: WatchStoreProtocol) {
        self.store = store
    }

    // MARK: - Navigation

    func presentHome()       { store?.transitionToHome() }
    func presentDraw()       { store?.transitionToDraw() }
    func presentChallenge()  { store?.transitionToChallenge() }
    func presentAccepted()   { store?.transitionToAccepted() }
    func presentInProgress() { store?.transitionToInProgress() }
    func presentCompleted()  { store?.transitionToCompleted() }

    // MARK: - Desafio (presets)

    func presentCategory(_ category: WatchCategory) {
        store?.displayCategory(category)
    }

    /// O desafio sorteado já vem pronto dos presets: só entrega para a Store.
    func presentDrawnChallenge(_ challenge: WatchChallenge) {
        store?.displayChallenge(challenge)
    }

    func presentAchievement(_ achievement: WatchAchievement) {
        store?.displayAchievement(achievement)
    }

    // MARK: - Cronômetro

    /// Recebe o tempo em segundos e entrega o texto "hh:mm:ss" para a Store.
    /// Formatar é papel do Presenter: o Interactor nunca monta texto de tela.
    /// Ex.: 3725s = 1h 02min 05s -> "01:02:05".
    func presentTime(_ elapsed: TimeInterval) {
        let total = Int(elapsed)
        let hours = total / 3600
        let minutes = (total % 3600) / 60
        let seconds = total % 60
        store?.displayTimer(String(format: "%02d:%02d:%02d", hours, minutes, seconds))
    }

    func presentPaused(_ isPaused: Bool) {
        store?.displayPaused(isPaused)
    }
}
