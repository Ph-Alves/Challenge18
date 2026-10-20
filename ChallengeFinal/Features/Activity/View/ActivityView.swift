//
//  ChallengeView.swift
//  ChallengeFinal
//
//  Created by Raquel Souza on 19/10/26.
//

import SwiftUI


//CHANGE: substituir isso daqui pela implementação real, isso é só um placeholder.
struct ActivityView: View {
    
    let coordinator: ActivityCoordinator
    @State private var interactor: ActivityInteractor

    init(coordinator: ActivityCoordinator, interactor: ActivityInteractor) {
        self.coordinator = coordinator
        _interactor = State(initialValue: interactor)
    }

    var body: some View {
        VStack(spacing: 24) {
            switch coordinator.step {
            case .draw:       Text("Sortear")
            case .challenge:  Text("Desafio")
            case .inProgress: Text("Em andamento")
            case .mood:       Text("Humor")
            case .photo:      Text("Foto")
            case .summary:    Text("Resumo")
            }
            
            Button("Próximo") {
                coordinator.debugNext() //substituir isso daqui pela implementação real, isso é só um placeholder.
            }
            .buttonStyle(.borderedProminent)
        }
        .animation(.default, value: coordinator.step)
    }
}
