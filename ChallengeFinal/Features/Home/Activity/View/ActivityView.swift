//
//  ChallengeView.swift
//  ChallengeFinal
//
//  Created by Raquel Souza on 19/10/26.
//

import SwiftUI


//CHANGE: substituir isso daqui pela implementação real, isso é só um placeholder.
struct ActivityView: View {
    
    let interactor: ActivityInteractorProtocol
    var store: ActivityStoreProtocol

    var body: some View {
        VStack(spacing: 24) {
            switch store.getCurrentStep() {
            case .draw:       Text("Sortear")
            case .challenge:  Text("Desafio")
            case .inProgress: Text("Em andamento")
            case .mood:       Text("Humor")
            case .photo:      Text("Foto")
            case .summary:    Text("Resumo")
            }
        }
        .animation(.default, value: store.getCurrentStep())
    }
}
