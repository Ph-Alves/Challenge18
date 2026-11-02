//
//  FeelingsPresenter.swift
//  ChallengeFinal
//
//  Created by Paulo Henrique Costa Alves on 02/11/26.
//

import Foundation

protocol FeelingsPresenterProtocol: AnyObject {
    func presentFeelingsLoaded(activities: [Activity])
}

@MainActor
final class FeelingsPresenter: FeelingsPresenterProtocol {
    weak var store: FeelingsStoreProtocol?
    
    init(store: FeelingsStoreProtocol) {
        self.store = store
    }
}
