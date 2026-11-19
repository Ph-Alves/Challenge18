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
