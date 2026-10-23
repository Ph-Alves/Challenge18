//
//  HomeCoordinatorView.swift
//  ChallengeFinal
//
//  Created by Raquel Souza on 19/10/26.
//

import SwiftUI

struct HomeView: View {

    // MARK: - Variables
    let interactor: HomeInteractorProtocol
    var store: HomeStore
    
    // MARK: - View
    var body: some View {
        VStack(spacing: 40) {
            WeeklyHumor(week: store.daysOfWeek)
                .padding(.bottom, 37)
            
            Text("Oi, desafie-se!")
                .font(.title.bold())

            ChallengeCircle(text: "Eu te ajudo no que fazer <3")
                .gesture(
                    DragGesture(minimumDistance: 20)
                        .onEnded { value in
                            let isHorizontalSwipe = abs(value.translation.width) > abs(value.translation.height)
                            guard isHorizontalSwipe else { return }

                            if value.translation.width < 0 {
                                interactor.nextCategory(current: store.currentCategory)
                            } else {
                                interactor.previousCategory(current: store.currentCategory)
                            }
                        }
                )
                .padding(.horizontal)

            
            CategoryText(category: store.currentCategory)
            
            Spacer()
        }
        .padding(.vertical)
        .onAppear() {
            interactor.getCurrentWeek()
        }
    }
}


// MARK: - Stub pro preview

private final class HomeInteractorStub: HomeInteractorProtocol {
    func getCurrentWeek() {}
    
    func nextCategory(current: ActivityCategory) {}
    
    func previousCategory(current: ActivityCategory) {}
}

extension HomeStore {
    static var preview: HomeStore {
        let state = HomeStore(coordinator: HomeCoordinator())
        
        state.daysOfWeek = ["D", "S", "T", "Q", "Q", "S", "S"]
        return state
    }
}

// MARK: - Preview
#Preview {
    HomeView(interactor: HomeInteractorStub(), store: .preview)
}
