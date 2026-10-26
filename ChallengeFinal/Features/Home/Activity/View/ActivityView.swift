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
            case .draw:
                DrawChallengeView(
                    isSearching: store.isSearching,
                    isChallengeReady: store.isChallengeReady,
                    startDetection: {
                        interactor.detectMotion(for: currentCategory)
                    }, finishDetection: {
                        interactor.finishDetection()
                    }, returnAction: {
                        interactor.finishActivity()
                    }, growFinished: {
                        interactor.goToActivityDetail()
                    })
                .transition(.opacity)

            case .challenge:
                if let title = store.activityTitle, let subtitle = store.activitySubtitle, let description = store.activityDescription {
                    if !store.isChallengeAccepted {
                        ChallengeDisplayView(challengeTitle: title, archiveAction: {
                            interactor.archiveChallenge(title: title, description: subtitle, in: currentCategory)
                            interactor.returnToStart()
                        }, acceptAction: {
                            interactor.acceptChallenge()
                        }, refuseAction: {
                            interactor.returnToStart()
                        })
                        .transition(.opacity)
                    } else {
                        ChallengeAcceptedView(challengeTitle: title, challengeSubTitle: subtitle, challengeDescription: description, startAction: {
                            interactor.startChallenge()
                        }, cancelAction: {
                            interactor.returnToStart()
                        })
                    }
                }
            case .inProgress: Text("Em andamento")
            case .mood:       Text("Humor")
            case .photo:      Text("Foto")
            case .summary:    Text("Resumo")
            }
        }
        .animation(.easeInOut(duration: 0.4), value: store.currentStep)
        .onAppear() {
            interactor.prepare(for: currentCategory)
        }
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
