//
//  ActivityCoordinator.swift
//  ChallengeFinal
//
//  Created by Raquel Souza on 19/10/26.
//

import Foundation
import SwiftUI
import SwiftData

/// Etapas do fluxo de Activity, em ordem:
/// sortear -> ver desafio -> em andamento -> humor -> foto -> resumo.
enum ActivityStep {
    case draw, challenge, inProgress, mood, photo, summary
}

/// Coordinator do fluxo de Activity: guarda em qual step estamos.
/// É @Observable, então a View troca de tela sozinha quando `step` muda.
@MainActor
@Observable
final class ActivityCoordinator {
    /// Step atual. Só muda pelos `goTo...` (somente leitura para quem está fora).
    private(set) var step: ActivityStep = .draw
    /// Categoria escolhida na Home, usada para gerar o desafio.
    private let selectedCategory: ActivityCategory
    /// Avisa a Home que o fluxo acabou (ela volta para `.home`).
    private let onFinish: () -> Void

    /// Cache da view para não reconstruir o fluxo a cada render da Home.
    var cached: ActivityView?

    init(selectedCategory: ActivityCategory, onFinish: @escaping () -> Void) {
        self.selectedCategory = selectedCategory
        self.onFinish = onFinish
    }

    /// Monta a view do fluxo pelo Builder na primeira vez e reaproveita nas seguintes.
    func startActivityView(context: ModelContext) -> ActivityView {
        if let cached = cached {
            return cached
        }

        let view = ActivityBuilder.build(coordinator: self, context: context, currentCategory: selectedCategory)
        cached = view
        return view
    }
}

// Cada função só troca o step; a View reage à mudança.
extension ActivityCoordinator: ActivityRouting {
    func goToDraw()       { step = .draw }
    func goToChallenge()  { step = .challenge }
    func goToInProgress() { step = .inProgress }
    func goToMood()       { step = .mood }
    func goToPhoto()      { step = .photo }
    func goToSummary()    { step = .summary }
    func finishFlow()     { onFinish() }
}
