//
//  FeelingsStore+mood.swift
//  ChallengeFinal
//
//  Created by Paulo Henrique Costa Alves on 02/11/26.
//

import Foundation

// MARK: - Carregamento

extension FeelingsStore {
    
    /// Guarda os sentimentos já agrupados. Como a Store é `@Observable`,
    /// o gráfico que lê `feelings` se atualiza sozinho.
    func presentFeelingsLoaded(feelings: [Humor: [Activity]]) {
        self.feelings = feelings
    }
    
    func presentActivityDetails(activity: Activity) {
        self.selectedActivity = activity
        self.presentDetail = true
    }
    
    func returnToFeelings() {
        self.presentDetail = false
    }
}
