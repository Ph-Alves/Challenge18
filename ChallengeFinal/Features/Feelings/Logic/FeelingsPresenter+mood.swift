//
//  FeelingsPresenter+Feelings.swift
//  ChallengeFinal
//
//  Created by Paulo Henrique Costa Alves on 02/11/26.
//

import Foundation

// MARK: - Carregamento

extension FeelingsPresenter {
    
    /// Agrupa as Activities por humor (ex.: `.happy` -> [Activity, Activity]),
    /// que é o formato que o gráfico precisa para contar cada barra.
    func presentFeelingsLoaded(activities: [Activity]) {
        // Descarta as que não têm humor registrado.
        let withHumor = activities.filter { $0.result?.humor != nil }
        // O `!` é seguro: o filtro acima garante que `result` existe.
        // Uso dicionário aqui por que consigo definir por chave valor e definir os labels
        // Não preciso de ordenação, então mais um motivo para se usar.
        let grouped = Dictionary(grouping: withHumor) { $0.result!.humor }
        
        store?.presentFeelingsLoaded(feelings: grouped)
    }
}
