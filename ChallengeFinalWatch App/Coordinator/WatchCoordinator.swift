//
//  WatchCoordinator.swift
//  ChallengeFinalWatch Watch App
//
//  Created by Paulo Henrique Costa Alves on 19/11/26.
//

import Foundation

/// Etapas do fluxo do Watch, em ordem:
/// home (seletor) -> sorteio -> "topa?" -> desafio aceito -> em andamento -> concluído.
enum WatchStep {
    case home, draw, challenge, accepted, inProgress, completed
}

/// Coordinator do Watch: guarda em qual step estamos.
/// É @Observable, então a View troca de tela sozinha quando `step` muda.
@MainActor
@Observable
final class WatchCoordinator {
    /// Step atual. Só muda pelos `goTo...` (somente leitura para quem está fora).
    private(set) var step: WatchStep = .home

    /// Cache da view para não reconstruir a cena a cada render de quem a exibe.
    /// Fora da observação: ela é preenchida durante o `body` do App.
    @ObservationIgnored var cachedView: HomeWatch?

    /// Monta a view pelo Builder na primeira vez e reaproveita nas seguintes.
    func startHomeView() -> HomeWatch {
        if let cachedView {
            return cachedView
        }

        let view = WatchBuilder.build(routing: self)
        cachedView = view
        return view
    }
}

// Cada função só troca o step; a View reage à mudança.
extension WatchCoordinator: WatchRouting {
    func goToHome()       { step = .home }
    func goToDraw()       { step = .draw }
    func goToChallenge()  { step = .challenge }
    func goToAccepted()   { step = .accepted }
    func goToInProgress() { step = .inProgress }
    func goToCompleted()  { step = .completed }
}
