//
//  ActivityPresenter+Draw.swift
//  ChallengeFinal
//
//  Created by Raquel Souza on 19/10/26.
//

import Foundation

// MARK: - Steps .draw e .challenge

/// Os requisitos estão declarados no `ActivityPresenterProtocol`.
extension ActivityPresenter {

    /// O sorteio terminou: entrega o desafio para a Store mostrar.
    func presentChallenge(_ challenge: FrictionChallenge) {
        store?.displayChallenge(challenge)
    }

    /// Começou a procurar: a tela troca os textos para "procurando...".
    func presentSearching() {
        store?.displaySearching()
    }

    /// O sorteio falhou: a tela volta ao estado de espera para tentar de novo.
    func presentSearchFailed() {
        store?.displaySearchFailed()
    }

    /// O usuário aceitou: o step continua `.challenge`, mas passa a mostrar
    /// a tela de desafio aceito (não é uma troca de step).
    func presentAcceptedActivity() {
        store?.displayAcceptedChallenge()
    }

    // MARK: Navigation

    /// Volta para o sorteio limpando o desafio anterior.
    func presentStartAgain() {
        store?.transitionToStart()
    }

    func presentMood() {
        store?.transitionToMood()
    }

    func presentPhoto() {
        store?.transitionToPhoto()
    }
}
