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
    func presentDrawnChallenge(_ challenge: WatchChallenge)
    func presentAchievement(_ achievement: WatchAchievement)
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

    /// O desafio sorteado já vem pronto dos presets: só entrega para a Store.
    func presentDrawnChallenge(_ challenge: WatchChallenge) {
        store?.displayChallenge(challenge)
    }

    func presentAchievement(_ achievement: WatchAchievement) {
        store?.displayAchievement(achievement)
    }
}
