//
//  AppCoordinator.swift
//  ChallengeFinal
//
//  Created by Raquel Souza on 19/10/26.
//

import Foundation
import Observation

enum AppTab: Hashable {
    
    case home, challenges, feelings, profile 
}

@MainActor //tudo que mexe com UI, precisa rodar na main thread.
@Observable //swiftUI sabe que precisa acompanhar esse objeto. sem ele, as abas na Tab não reagiram à mudanças.

final class AppCoordinator {
    
    var selectedTab: AppTab = .home
    let homeCoordinator = HomeCoordinator()
}

