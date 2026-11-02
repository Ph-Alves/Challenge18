//
//  FeelingsInteractor.swift
//  ChallengeFinal
//
//  Created by Paulo Henrique Costa Alves on 02/11/26.
//

import Foundation

protocol FeelingsInteractorProtocol: AnyObject {
    func loadFeelings()
}

@MainActor
final class FeelingsInteractor: FeelingsInteractorProtocol {
    let presenter: FeelingsPresenterProtocol
    let activityRepository: GenericRepository<Activity>
    
    init(presenter: FeelingsPresenterProtocol, activityRepository: GenericRepository<Activity>) {
        self.presenter = presenter
        self.activityRepository = activityRepository
    }
}
