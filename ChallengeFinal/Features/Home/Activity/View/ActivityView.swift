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
    let currentCategory: ActivityCategory
    var store: ActivityStore

    // MARK: - View
    var body: some View {
        VStack(spacing: 24) {
            switch store.currentStep {
            case .draw:       Text("desenho")
            case .challenge:  Text("Desafio")
            case .inProgress: Text("Em andamento")
            case .mood:       Text("Humor")
            case .photo:      Text("Foto")
            case .summary:    Text("Resumo")
            }
        }
        .animation(.easeInOut(duration: 0.4), value: store.currentStep)
    }
}

// MARK: - Stubs pro preview

final class ActivityInteractorStub: ActivityInteractorProtocol {
    func detectMotion(for category: ActivityCategory) {}
    
    func archiveChallenge(title: String, description: String, in category: ActivityCategory) {}
    
    func reroll(for category: ActivityCategory) {}
    
    func acceptChallenge() {}
    
    func startChallenge() {}
    
    func goToActivityDetail() {}
    
    func returnToStart() {}
    
    func finishDetection() {}
    
    func finishActivity() {}
    
    func prepare(for category: ActivityCategory) {}
}

extension ActivityStore {
    static var preview: ActivityStore {
        return ActivityStore(coordinator: ActivityCoordinator(selectedCategory: .cognitive, onFinish: {}))
    }
}

// MARK: - Preview
#Preview {
    ActivityView(interactor: ActivityInteractorStub(), currentCategory: .cognitive, store: .preview)
}
