//
//  ActivityStore+Draw.swift
//  ChallengeFinal
//
//  Created by Raquel Souza on 19/10/26.
//

import Foundation

// MARK: - Steps .draw e .challenge

/// Os requisitos estão declarados no `ActivityStoreProtocol` e o estado
/// (`isSearching`, `activityTitle`...) fica no `ActivityStore.swift`.
extension ActivityStore {

    // MARK: Display

    /// Guarda o desafio sorteado e marca como pronto.
    func displayActivity(_ challenge: FrictionChallenge) {
        self.activityTitle = challenge.title
        self.activitySubtitle = challenge.subTitle
        self.activityDescription = challenge.rationale
        self.isSearching = false
        // A view anima a bola e só depois chama transitionToChallenge()
        self.isChallengeReady = true
    }

    /// Também desfaz o "aceito": um novo sorteio (reroll) volta para a tela do desafio.
    func displaySearching() {
        self.isSearching = true
        self.isChallengeAccepted = false
    }

    func displaySearchFailed() {
        self.isSearching = false
    }

    func displayAcceptedActivity() {
        self.isChallengeAccepted = true
    }

    // MARK: Transitions

    /// Volta para o sorteio já com o estado limpo, para gerar um novo desafio.
    func transitionToStart() {
        self.isSearching = false
        self.isChallengeReady = false
        self.isChallengeAccepted = false
        self.coordinator.goToChallenge()
    }

    func transitionToMood() {
        self.coordinator.goToMood()
    }

    func transitionToPhoto() {
        self.coordinator.goToPhoto()
    }
}
