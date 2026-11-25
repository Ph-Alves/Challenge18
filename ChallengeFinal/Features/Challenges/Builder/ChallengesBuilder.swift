//
//  ChallengesBuilder.swift
//  ChallengeFinal
//
//  Created by Raquel Souza on 03/11/26.
//

import SwiftUI
import SwiftData

enum ChallengesBuilder {
    @MainActor
    static func build(context: ModelContext) -> ChallengesView {
        let store = ChallengesStore()
        let presenter = ChallengesPresenter(store: store)
        // A mesma câmera vai para o Interactor (que liga a sessão) e para o preview (que a mostra).
        // Se o Interactor criasse a própria, o preview mostraria uma sessão que nunca liga (tela preta).
        let camera = CameraWorker()
        let interactor = ChallengesInteractor(repository: GenericRepository<Activity>(context: context), presenter: presenter, camera: camera)
        
        return ChallengesView(interactor: interactor, store: store, cameraPreview: CameraPreview(session: camera.session))
    }
}
