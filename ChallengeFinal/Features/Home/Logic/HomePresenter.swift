//
//  HomePresenter.swift
//  ChallengeFinal
//
//  Created by Raquel Souza on 16/10/26.
//

protocol HomePresenterProtocol: AnyObject {
    func presentGroups(_ groups: [Category])
}

@MainActor
final class HomePresenter: HomePresenterProtocol {
    weak var store: HomeStoreProtocol?
    
    init(store: HomeStoreProtocol) {
        self.store = store
    }
    
    func presentGroups(_ groups: [Category]) {
        store?.displayCategory(groups: groups)
    }
}
