//
//  ChallengeView.swift
//  ChallengeFinal
//
//  Created by Raquel Souza on 19/10/26.
//

import SwiftUI


struct ActivityView: View {
    
    // MARK: - Variables
    let interactor: ActivityInteractorProtocol
    var store: ActivityStore

    // MARK: - View
    var body: some View {
        VStack(spacing: 24) {
            switch store.displayCurrentStep() {
            case .draw:
                DrawChallengeView(returnAction: {
                    interactor.finishActivity()
                })
            case .challenge:  Text("Desafio")
            case .inProgress: Text("Em andamento")
            case .mood:       Text("Humor")
            case .photo:      Text("Foto")
            case .summary:    Text("Resumo")
            }
        }
        .animation(.default, value: store.displayCurrentStep())
    }
}

// MARK: - Stubs pro preview

final class ActivityInteractorStub: ActivityInteractorProtocol {
    func finishActivity() {}
}

extension ActivityStore {
    static var preview: ActivityStore {
        return ActivityStore(coordinator: ActivityCoordinator(onFinish: {}))
    }
}

// MARK: - Preview
#Preview {
    ActivityView(interactor: ActivityInteractorStub(), store: .preview)
}
