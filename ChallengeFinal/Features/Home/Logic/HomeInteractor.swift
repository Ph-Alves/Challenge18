//
//  HomeInteractor.swift
//  ChallengeFinal
//
//  Created by Raquel Souza on 16/10/26.
//

protocol HomeInteractorProtocol: AnyObject {
    func getCategory()
}

final class HomeInteractor {
    
    private let repository: GenericRepository<Activity>
    private let presenter: HomePresenterProtocol
    
    init(repository: GenericRepository<Activity>, presenter: HomePresenterProtocol) {
        self.repository = repository
        self.presenter = presenter
    }
    
    func getCategory() {
        let categories = Category.allCases
        presenter.presentGroups(categories)
    }
}
