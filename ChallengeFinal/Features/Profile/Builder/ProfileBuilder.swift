//
//  ProfileBuilder.swift
//  ChallengeFinal
//
//  Created by Raquel Souza on 16/10/26.
//

import Foundation
import SwiftData

///
/// É o ÚNICO lugar que conhece as classes concretas. Todo o resto se enxerga por protocolo.
/// Ordem de criação: Store -> Presenter(store) -> Interactor(presenter, repositórios) -> View
enum ProfileBuilder {
    @MainActor
    static func build(context: ModelContext) -> ProfileView {
        let store = ProfileStore()
        let presenter = ProfilePresenter(store: store)
        let interactor = ProfileInteractor(
            presenter: presenter,
            profileRepository: GenericRepository<Profile>(context: context),
            activityRepository: GenericRepository<Activity>(context: context)
        )

        // A View segura a Store com força: o Presenter guarda a Store como `weak`.
        return ProfileView(interactor: interactor, store: store)
    }
}
