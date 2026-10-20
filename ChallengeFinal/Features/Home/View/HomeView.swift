//
//  HomeCoordinatorView.swift
//  ChallengeFinal
//
//  Created by Raquel Souza on 19/10/26.
//

import SwiftUI

//CHANGE: substituir isso daqui pela implementação real, isso é só um placeholder.
struct HomeView: View {
    @Bindable var coordinator: HomeCoordinator

    var body: some View {
        Button("Sortear desafio") {
            coordinator.startChallengeFlow() //CHANGE: Placeholder apenas para verificar como a navegação deve acontecer, deve ser substituida pela linha abaixo.
//            HomeBuilder.build(routing: coordinator) ////->descomentar linha abaixo após a implementação do builder da Home
        }
        .fullScreenCover(item: $coordinator.activeChallengeFlow) { flow in
                ChallengesBuilder.build(coordinator: flow)
        }
    }
}
