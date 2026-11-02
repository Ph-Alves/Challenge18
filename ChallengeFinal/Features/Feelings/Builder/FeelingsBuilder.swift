//
//  FeelingsBuilder.swift
//  ChallengeFinal
//
//  Created by Paulo Henrique Costa Alves on 02/11/26.
//

import Foundation
import SwiftData

enum FeelingsBuilder {
    
    @MainActor
    static func build(context: ModelContext) -> FeelingsView {
        let store = FeelingsStore()
        
        let presenter = FeelingsPresenter(store: store)
        
        let interactor = FeelingsInteractor(presenter: presenter, activityRepository: GenericRepository(context: context))
        
        return FeelingsView(interactor: interactor, store: store)
    }
}
