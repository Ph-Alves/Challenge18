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

struct HomeWatch: View {
    
    // Para executar
    let interactor: WatchInteractorProtocol
    // Para observar
    var store: WatchStore
    
    var body: some View {
        NavigationStack {
            CategorySelector(startFlow: interactor.startActivity)
        }
    }
}

#Preview {
    WatchBuilder.build(routing: WatchCoordinator())
}
