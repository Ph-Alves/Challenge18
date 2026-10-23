//
//  HomeCoordinator.swift
//  ChallengeFinal
//
//  Created by Raquel Souza on 19/10/26.
//

import Foundation
import SwiftUI
import SwiftData

@MainActor
@Observable
final class HomeCoordinator: HomeRouting {
    
    @ObservationIgnored var cachedHomeView: HomeView?
    var activeChallengeFlow: ActivityCoordinator? = nil
    
    func startChallengeFlow() {
        //ok, isso é uma closure para "quando o fluxo acabar, execute o onfinish).
        //o self aqui remete a HomeCoordinator, pois foi ele quem "escreveu o bilhete".
        activeChallengeFlow = ActivityCoordinator(onFinish: { [weak self] in
                    self?.activeChallengeFlow = nil
        })
    }
    
    func startHome(context: ModelContext) -> HomeView {
        if let cached = cachedHomeView {
            return cached
        }
        
        let view = HomeBuilder.build(routing: self, context: context)
        cachedHomeView = view
        return view
    }
}

