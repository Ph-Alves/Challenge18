//
//  FeelingsCoordinator.swift
//  ChallengeFinal
//
//  Created by Paulo Henrique Costa Alves on 02/11/26.
//

import Foundation
import SwiftData

/// Coordinator da tela de Feelings.
/// Por enquanto não há navegação interna: ele só monta a view pelo Builder
/// e guarda em cache.
@MainActor
final class FeelingsCoordinator: FeelingsRouting {
    
    /// Cache da view para não reconstruir a cena a cada render de quem a exibe.
    var cached: FeelingsView?
    
    /// Monta a view pelo Builder na primeira vez e reaproveita nas seguintes.
    func startFeelingsView(context: ModelContext) -> FeelingsView {
        if let cached {
            return cached
        }
        
        let view = FeelingsBuilder.build(context: context)
        cached = view
        return view
    }
}
