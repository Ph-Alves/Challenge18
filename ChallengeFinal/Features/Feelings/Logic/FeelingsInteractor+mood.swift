//
//  FeelingsInteractor+mood.swift
//  ChallengeFinal
//
//  Created by Paulo Henrique Costa Alves on 02/11/26.
//

import Foundation

// MARK: - Carregamento

extension FeelingsInteractor {
    
    /// Busca as Activities do banco e manda para o Presenter.
    /// Só entram as que têm `result`: sem resultado, o usuário não chegou a
    /// registrar o humor, então não contam nos sentimentos.
    func loadFeelings() {
        do {
            let activities = try self.activityRepository.getAll().filter { $0.result != nil }
            presenter.presentFeelingsLoaded(activities: activities)
        } catch {
            print("Erro ao buscar atividades: \(error.localizedDescription)")
        }
    }
}
