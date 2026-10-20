//
//  HomeCoordinator.swift
//  ChallengeFinal
//
//  Created by Raquel Souza on 19/10/26.
//

import Foundation
import SwiftUI

@MainActor
@Observable
final class HomeCoordinator: HomeRouting {
    
    var activeChallengeFlow: ChallengesCoordinator? = nil
    
    func startChallengeFlow() {
        //ok, isso é uma closure para "quando o fluxo acabar, execute o onfinish).
        //o self aqui remete a HomeCoordinator, pois foi ele quem "escreveu o bilhete".
        activeChallengeFlow = ChallengesCoordinator(onFinish: { [weak self] in
                    self?.activeChallengeFlow = nil
        })
    }
}

