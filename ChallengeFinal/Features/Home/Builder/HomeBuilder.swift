//
//  HomeBuilder.swift
//  ChallengeFinal
//
//  Created by Raquel Souza on 16/10/26.
//

//Builder sabe como montar uma cena (cria View + Interactor + Presenter e liga tudo).
//Coordinator sabe quando e onde mostrar essa cena.
import SwiftUI
import SwiftData

enum HomeBuilder {
    @MainActor
    static func build(routing: HomeRouting, context: ModelContext) -> some View {
        let store = HomeStore(coordinator: routing)
        let presenter = HomePresenter(store: store)
        let interactor = HomeInteractor(repository: GenericRepository<Activity>(context: context), presenter: presenter)
        
        return HomeView(interactor: interactor, store: store)
    }
}
