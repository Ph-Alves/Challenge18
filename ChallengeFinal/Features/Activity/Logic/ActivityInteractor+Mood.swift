//
//  ActivityInteractor+Mood.swift
//  ChallengeFinal
//
//  Created by Raquel Souza on 28/10/26.
//

import Foundation

// MARK: - Step .mood

/// O humor escolhido fica em `selectedHumor` (vai para o `ActivityResult`
/// no resumo). O "continuar" é o `selectMood()`, no arquivo principal.
extension ActivityInteractor {

    /// Swipe para a esquerda: o humor da direita vem para o topo.
    func nextHumor() {
        moveHumor(by: 1)
    }

    /// Swipe para a direita: o humor da esquerda vem para o topo.
    func previousHumor() {
        moveHumor(by: -1)
    }

    // MARK: - Auxiliares privados

    /// Anda `offset` posições na roleta, dando a volta nas pontas
    /// (depois do último vem o primeiro, e vice-versa).
    private func moveHumor(by offset: Int) {
        let humors = Humor.allCases
        let current = selectedHumor ?? .chill

        guard let index = humors.firstIndex(of: current) else { return }

        let newIndex = (index + offset + humors.count) % humors.count
        let humor = humors[newIndex]

        selectedHumor = humor
        presenter.presentHumor(humor)
        
        // Tique a cada fatia que passa pelo marcador.
        hapticWorker.playSelectionTick()
    }
}
