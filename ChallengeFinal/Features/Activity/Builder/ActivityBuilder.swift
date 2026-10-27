//
//  ActivityBuilder.swift
//  ChallengeFinal
//
//  Created by Raquel Souza on 16/10/26.
//

import SwiftUI
import SwiftData

/// Monta a cena VIP do fluxo de Activity.
///
/// É o ÚNICO lugar que conhece as classes concretas (`ActivityStore`,
/// `CameraWorker`, `ActivityPresenter`...). Todo o resto se enxerga por protocolo.
///
/// Ordem de criação (cada um depende do anterior):
/// Store -> Presenter(store) -> Interactor(presenter, workers) -> View
enum ActivityBuilder {
    @MainActor
    static func build(coordinator: ActivityCoordinator, context: ModelContext, currentCategory: ActivityCategory) -> ActivityView {
        let store = ActivityStore(coordinator: coordinator)
        
        let presenter = ActivityPresenter(store: store)
        
        let camera = CameraWorker()
        
        // Só entrega os ticks (1 por segundo); o tempo em si é calculado no Interactor.
        let timer = TimerWorker()
        // Abre, para e cancela a Live Activity (Dynamic Island). O grupo da atividade
        // (`currentCategory`) vai para o Interactor, que o repassa à ilha.
        let liveActivity = WidgetWorker()
        
        
        let interactor = ActivityInteractor(
            presenter: presenter,
            activityRepository: GenericRepository<Activity>(context: context),
            hapticWorker: HapticsWorker(),
            coreMotionWorker: CoreMotionWorker(),
            foundationWorker: FoundationWorker(),
            camera: camera,
            timer: timer, liveActivity: liveActivity, currentCategory: currentCategory)
        
        // A View segura a Store com força: o Presenter guarda a Store como `weak`.
        return ActivityView(
            interactor: interactor,
            store: store,
            cameraPreview: CameraPreviewView(session: camera.session),
            currentCategory: currentCategory
        )
    }
}
