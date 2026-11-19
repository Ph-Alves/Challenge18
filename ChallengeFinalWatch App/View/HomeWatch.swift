//
//  HomeWatch.swift
//  ChallengeFinalWatch Watch App
//
//  Created by Paulo Henrique Costa Alves on 19/11/26.
//

import SwiftUI

enum WatchCategory: CaseIterable {
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
    
    // CHANGE: os dados abaixo são fixos só para as telas; virão da Store quando houver sorteio e cronômetro.
    private let sampleCategory: WatchCategory = .physical
    private let sampleTitle = "fazer o cardio sem abrir as redes sociais"
    private let sampleDescription = "sem redes sociais, seu cardio vira um momento para cuidar do corpo e desacelerar a mente."
    private let sampleTime = "00:00:00"
    
    var body: some View {
        NavigationStack {
            stepView
        }
    }
    
    // MARK: - Steps
    
    @ViewBuilder
    private var stepView: some View {
        switch store.currentStep {
            
        // Seletor de categoria: o toque no círculo inicia o sorteio.
        case .home:
            CategorySelector(startFlow: interactor.startActivity)
            
        // Sorteio. Por enquanto o toque na bola simula o sorteio.
        case .draw:
            DrawWatch(
                category: sampleCategory,
                onDraw: interactor.finishDraw,
                onBack: { interactor.didTapBack(on: .draw) }
            )
            
        // "topa?": aceitar segue; "outro desafio" ainda não tem lógica.
        case .challenge:
            ChallengeWatch(
                title: sampleTitle,
                onAccept: interactor.acceptChallenge,
                onReroll: { },
                onBack: { interactor.didTapBack(on: .challenge) }
            )
            
        // Desafio aceito: "iniciar" começa o cronômetro; o X sai do fluxo.
        case .accepted:
            AcceptedWatch(
                title: sampleTitle,
                description: sampleDescription,
                onStart: interactor.startTimer,
                onClose: interactor.didTapClose
            )
            
        // Em andamento: parar segue para o "arrasou"; pausar ainda não tem lógica.
        case .inProgress:
            InProgressWatch(
                timeText: sampleTime,
                onPause: { },
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
