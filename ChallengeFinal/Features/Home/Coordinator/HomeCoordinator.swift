//
//  HomeCoordinator.swift
//  ChallengeFinal
//
//  Created by Raquel Souza on 19/10/26.
//

import Foundation
import SwiftUI
import SwiftData

// MARK: - Class
@MainActor
@Observable
final class HomeCoordinator: HomeRouting {
    
    // guarda a view como um cache para não precisar renderizar nova view
    // usa observationIgnored por que a view não deve renderizar 2x
    // ja que esse valor atualiza enquanto renderiza a view no startHome()
    @ObservationIgnored var cachedHomeView: HomeView?
    // Flluxo do Challenge
    var activeChallengeFlow: ActivityCoordinator? = nil
    
    // Começa o fluxo do challenge (pendente)
    func startChallengeFlow() {
        //ok, isso é uma closure para "quando o fluxo acabar, execute o onfinish).
        //o self aqui remete a HomeCoordinator, pois foi ele quem "escreveu o bilhete".
        activeChallengeFlow = ActivityCoordinator(onFinish: { [weak self] in
                    self?.activeChallengeFlow = nil
        })
    }
    
    // Chama o builder para montar a view da home (não tem fluxo na home necessariamente)
    func startHome(context: ModelContext) -> HomeView {
        if let cached = cachedHomeView {
            return cached
        }
        
        let view = HomeBuilder.build(routing: self, context: context)
        cachedHomeView = view
        return view
    }
}

