//
//  ActivityBuilder.swift
//  ChallengeFinal
//
//  Created by Raquel Souza on 16/10/26.
//

import SwiftUI

/// Monta a cena VIP do fluxo de Activity.
///
/// É o ÚNICO lugar que conhece as classes concretas (`ActivityStore`,
/// `CameraWorker`, `ActivityPresenter`...). Todo o resto se enxerga por protocolo.
///
/// Ordem de criação (cada um depende do anterior):
/// Store -> Worker -> Presenter(store) -> Interactor(presenter, routing, worker) -> View
enum ActivityBuilder {

    @MainActor
    static func build(coordinator: ActivityCoordinator) -> some View {
        // 1. Estado da tela.
        let store = ActivityStore()

        // 2. Workers (infraestrutura).
        let camera = CameraWorker()

        // 3. Presenter: escreve na Store.
        let presenter = ActivityPresenter(store: store)

        // 4. Interactor: usa o Presenter, o Worker e avisa o Coordinator.
        let interactor = ActivityInteractor(
            presenter: presenter,
            routing: coordinator,
            camera: camera
        )

        // 5. View: recebe o que precisa para LER (store, session)
        //    e para AGIR (interactor, coordinator).
        //
        //    A View segura a Store com força. Isso é importante porque o
        //    Presenter guarda a Store como `weak`: se a View não segurasse,
        //    a Store seria liberada aqui mesmo, ao fim desta função.
        //

        return ActivityView (
            coordinator: coordinator,
            interactor: interactor,
            store: store,
            cameraPreview: CameraPreviewView(session: camera.session)
        )
    }
}
