//
//  FeelingsInteractor+mood.swift
//  ChallengeFinal
//
//  Created by Paulo Henrique Costa Alves on 02/11/26.
//

import Foundation

extension FeelingsInteractor {
    
    func loadFeelings() {
        do {
            let activities = try self.activityRepository.getAll().filter { $0.result != nil }
            presenter.presentFeelingsLoaded(activities: activities)
        } catch {
            print("Erro ao buscar atividades: \(error.localizedDescription)")
        }
    }
}
