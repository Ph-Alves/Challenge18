//
//  WatchInteractor.swift
//  ChallengeFinalWatch Watch App
//
//  Created by Paulo Henrique Costa Alves on 19/11/26.
//

import Foundation

// MARK: - Protocol

/// O que as Views enxergam do Interactor: só as AÇÕES que o usuário pode fazer.
///
/// Com o protocolo, a View não depende da classe concreta. Nos testes e nos
/// `#Preview`, dá para passar um Interactor falso que só anota os toques.
@MainActor
protocol WatchInteractorProtocol: AnyObject {
    // MARK: Navigation
    func startActivity()
    func finishDraw()
    func acceptChallenge()
    func startTimer()
    func finishActivity()
    func returnToHome()
    func didTapBack(on step: WatchStep)
    func didTapClose()
}

// MARK: - Class

/// O "cérebro" do Watch.
///
/// Decide o que acontece em cada ação do usuário e avisa o Presenter.
/// Por enquanto só tem a navegação entre os steps.
@MainActor
final class WatchInteractor: WatchInteractorProtocol {

    // MARK: - Dependências

    /// Para quem o Interactor manda os resultados. Pelo protocolo, para dar spy nos testes.
    let presenter: WatchPresenterProtocol

    // MARK: - Init

    init(presenter: WatchPresenterProtocol) {
        self.presenter = presenter
    }

    // MARK: - Navigation

    /// Toque no círculo da categoria na home: vai para o sorteio.
    func startActivity() {
        presenter.presentDraw()
    }

    /// O sorteio terminou (o relógio foi sacudido): mostra o "topa?".
    func finishDraw() {
        presenter.presentChallenge()
    }

    /// "aceitar": mostra o desafio aceito.
    func acceptChallenge() {
        presenter.presentAccepted()
    }

    /// "iniciar": começa o cronômetro.
    func startTimer() {
        presenter.presentInProgress()
    }

    /// Botão de parar o cronômetro: vai para o "arrasou".
    func finishActivity() {
        presenter.presentCompleted()
    }

    /// "home" no "arrasou": volta para o seletor de categoria.
    func returnToHome() {
        presenter.presentHome()
    }

    /// Seta de voltar (steps `.draw` e `.challenge`).
    /// Aqui eu to definindo quem "deve voltar" pra quem.
    func didTapBack(on step: WatchStep) {
        switch step {
        case .draw:
            presenter.presentHome()      // volta pro seletor
        case .challenge:
            presenter.presentDraw()      // volta pro sorteio
        case .home, .accepted, .inProgress, .completed:
            break  // esses steps não têm seta
        }
    }

    /// X (steps `.accepted` e `.inProgress`): sai do fluxo e volta para a home.
    func didTapClose() {
        presenter.presentHome()
    }
}
