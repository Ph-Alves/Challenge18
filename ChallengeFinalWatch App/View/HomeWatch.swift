//
//  HomeWatch.swift
//  ChallengeFinalWatch Watch App
//
//  Created by Paulo Henrique Costa Alves on 19/11/26.
//

import SwiftUI

/// O `rawValue` é o mesmo do `ActivityCategory` do iOS: é ele que viaja no `WatchActivityPayload`.
enum WatchCategory: String, CaseIterable {
    case physical, cognitive, sensorial, social
    var imageName: String {
        switch self {
        case .physical:
            "eightBall"
        case .cognitive:
            "coffee"
        case .sensorial:
            "cookie"
        case .social:
            "telephone"
        }
    }
    var text: String {
        switch self {
        case .physical:
            "movimento"
        case .cognitive:
            "mente"
        case .sensorial:
            "sentidos"
        case .social:
            "conexão"
        }
    }
}

/// Container do fluxo do Watch: mostra a view do step atual
/// e liga os toques de cada step ao Interactor.
struct HomeWatch: View {
    
    // Para executar
    let interactor: WatchInteractorProtocol
    // Para observar
    var store: WatchStore
    
    var body: some View {
        NavigationStack {
            stepView
        }
    }
    
    // MARK: - Steps
    
    @ViewBuilder
    private var stepView: some View {
        switch store.currentStep {
            
        // Seletor de categoria: o toque no círculo guarda a categoria e inicia o sorteio.
        case .home:
            CategorySelector(startFlow: interactor.startActivity(category:))
            
        // Sorteio: chacoalhar o relógio (detectado no Interactor) ou tocar na bola levam ao "topa?".
        case .draw:
            DrawWatch(
                category: store.category,
                onDraw: interactor.finishDraw,
                onBack: { interactor.didTapBack(on: .draw) }
            )
            
        // "topa?": aceitar segue; "outro desafio" sorteia outro preset da mesma categoria.
        case .challenge:
            ChallengeWatch(
                title: store.challenge?.title ?? "",
                onAccept: interactor.acceptChallenge,
                onReroll: { interactor.rerollChallenge(for: store.category) },
                onBack: { interactor.didTapBack(on: .challenge) }
            )
            
        // Desafio aceito: "iniciar" começa o cronômetro; o X sai do fluxo.
        case .accepted:
            AcceptedWatch(
                title: store.challenge?.title ?? "",
                description: store.challenge?.rationale ?? "",
                onStart: interactor.startTimer,
                onClose: interactor.didTapClose
            )
            
        // Em andamento: o cronômetro já começou ao entrar aqui. Esquerda pausa/retoma; direita para e segue para o "arrasou".
        case .inProgress:
            InProgressWatch(
                timeText: store.timeText,
                isPaused: store.isPaused,
                onTogglePause: interactor.togglePause,
                onStop: interactor.finishActivity,
                onClose: interactor.didTapClose
            )
            
        // "arrasou": o botão volta para a home.
        case .completed:
            CompletedWatch(
                onHome: interactor.returnToHome,
                onClose: interactor.finishActivity)
        }
    }
}

#Preview {
    WatchBuilder.build(routing: WatchCoordinator())
}
