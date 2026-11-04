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
        let interactor = ChallengesInteractor(repository: GenericRepository<Activity>(context: context), presenter: presenter)
        let camera = CameraWorker()
        
        return ChallengesView(interactor: interactor, store: store, cameraPreview: CameraPreview(session: camera.session))
    }
}
