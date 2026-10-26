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
            switch store.displayCurrentStep() {
            case .draw:
                DrawChallengeView(startDetection: {
                    interactor.detectMotion(for: currentCategory)
                }, finishDetection: {
                    interactor.finishDetection()
                }, returnAction: {
                    interactor.finishActivity()
                })
                
            case .challenge:
                if let title = store.activityTitle {
                    ChallengeDisplayView(challengeTitle: title, archiveAction: {
                        
                    }, acceptAction: {
                        
                    }, refuseAction: {
                        
                    })
                }
            case .inProgress: Text("Em andamento")
            case .mood:       Text("Humor")
            case .photo:      Text("Foto")
            case .summary:    Text("Resumo")
            }
        }
        .animation(.default, value: store.displayCurrentStep())
        .onAppear() {
            interactor.prepare(for: currentCategory)
        }
    }
}

// MARK: - Stubs pro preview

final class ActivityInteractorStub: ActivityInteractorProtocol {
    func prepare(for category: ActivityCategory) {}
    
    func detectMotion(for category: ActivityCategory) {}
    
    func detectMotion() {}
    
    func finishDetection() {}
    
    func finishActivity() {}
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
