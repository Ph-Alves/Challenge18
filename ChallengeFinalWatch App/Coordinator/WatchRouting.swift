//
//  WatchRouting.swift
//  ChallengeFinalWatch Watch App
//
//  Created by Paulo Henrique Costa Alves on 19/11/26.
//

import Foundation

/// O que a Store e quem exibe o fluxo enxergam do Coordinator:
/// em qual step estamos, como trocar de step e a view inicial já montada.
@MainActor
protocol WatchRouting: AnyObject {
    var step: WatchStep { get }

    /// View já montada, para ser reaproveitada.
    var cachedView: HomeWatch? { get set }

    /// Devolve a view inicial (montando pelo Builder se ainda não existir).
    func startHomeView() -> HomeWatch

    func goToHome()
    func goToDraw()
    func goToChallenge()
    func goToAccepted()
    func goToInProgress()
    func goToCompleted()
}
