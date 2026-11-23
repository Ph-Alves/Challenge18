//
//  WatchBuilder.swift
//  ChallengeFinalWatch Watch App
//
//  Created by Paulo Henrique Costa Alves on 19/11/26.
//

import Foundation

/// Monta a cena VIP do Watch.
///
/// É o ÚNICO lugar que conhece as classes concretas (`WatchStore`,
/// `WatchPresenter`, `WatchInteractor`). Todo o resto se enxerga por protocolo.
/// O Builder só monta: guardar a view em cache é papel do Coordinator.
///
/// Ordem de criação (cada um depende do anterior):
/// Store(routing) -> Presenter(store) -> Interactor(presenter) -> View
enum WatchBuilder {

    @MainActor
    static func build(routing: WatchRouting) -> HomeWatch {
        let store = WatchStore(coordinator: routing)
        let presenter = WatchPresenter(store: store)
        let interactor = WatchInteractor(presenter: presenter, timer: WatchTimerWorker())

        return HomeWatch(interactor: interactor, store: store)
    }
}
