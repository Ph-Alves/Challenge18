//
//  TimerTest.swift
//  ChallengeFinal
//
//  Created by Débora Cristina Silva Ferreira on 26/10/26.
//

import Foundation
import SwiftUI
import SwiftData

struct InProgressView: View {
    let store: ActivityStore
    let interactor: ActivityInteractorProtocol
    
    var body: some View {
        VStack(spacing: 16) {
            ChallengeCircle(text: "Teste de view", size: .medium)
            
        }
    }
}
#Preview {
    // Banco só em memória: o Interactor pede um repositório, mas o teste não salva nada.
    let container = try! ModelContainer(
        for: Activity.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )

    let coordinator = ActivityCoordinator(selectedCategory: .physical, onFinish: {})
    let store = ActivityStore(coordinator: coordinator)
    let presenter = ActivityPresenter(store: store)

    let interactor = ActivityInteractor(
        presenter: presenter,
        activityRepository: GenericRepository<Activity>(context: container.mainContext),
        hapticWorker: HapticsWorker(),
        coreMotionWorker: CoreMotionWorker(),
        foundationWorker: FoundationWorker(),
        camera: CameraWorker(),
        timer: TimerWorker()
    )

    return InProgressView(store: store, interactor: interactor)
}

