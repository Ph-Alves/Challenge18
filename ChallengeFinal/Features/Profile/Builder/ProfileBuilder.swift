//
//  ProfileBuilder.swift
//  ChallengeFinal
//
//  Created by Raquel Souza on 16/10/26.
//

/*
 // Prepara a view e retorna a mesma.
 enum HomeBuilder {
     @MainActor
     static func build(routing: HomeRouting, context: ModelContext) -> HomeView {
         let store = HomeStore(coordinator: routing)
         let presenter = HomePresenter(store: store)
         let interactor = HomeInteractor(repository: GenericRepository<Activity>(context: context), presenter: presenter)
         
         return HomeView(interactor: interactor, store: store)
     }
 }
 */

import Foundation

enum ProfileBuilder {
    @MainActor
    static func build() -> ProfileView {
        
        
        return ProfileView
    }
}
