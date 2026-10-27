//
//  HomeCoordinator.swift
//  ChallengeFinal
//
//  Created by Raquel Souza on 19/10/26.
//

import Foundation
import SwiftUI
import SwiftData

// MARK: - Enum
// Telas possíveis a partir da Home.
// `.activity` carrega o Coordinator do fluxo filho: a Home é dona dele,
// e quando o fluxo termina (onFinish) voltamos para `.home`.
enum HomeStep {
    case home
    case activity(ActivityCoordinator)
}

// MARK: - Class
// Coordinator da Home: decide QUANDO mostrar cada tela (Home ou fluxo de Activity).
// É @Observable para a RootView reagir às mudanças de `step`.
@MainActor
@Observable
final class HomeCoordinator: HomeRouting {
    
    private(set) var step: HomeStep = .home
    
    // guarda a view como um cache para não precisar renderizar nova view
    // usa observationIgnored por que a view não deve renderizar 2x
    // ja que esse valor atualiza enquanto renderiza a view no startHome()
    @ObservationIgnored var cached: HomeView?
    
    // Começa o fluxo do challenge (pendente)
    func startActivityFlow(category: ActivityCategory) {
        //ok, isso é uma closure para "quando o fluxo acabar, execute o onfinish).
        //o self aqui remete a HomeCoordinator, pois foi ele quem "escreveu o bilhete".
        let flow = ActivityCoordinator(selectedCategory: category, onFinish: { [weak self] in
            self?.step = .home
        })
        step = .activity(flow)
    }
    
    // Chama o builder para montar a view da home (não tem fluxo na home necessariamente)
    func startHomeFlow(context: ModelContext) -> HomeView {
        if let cached = cached {
            return cached
        }
        
        let view = HomeBuilder.build(routing: self, context: context)
        cached = view
        return view
    }
}

