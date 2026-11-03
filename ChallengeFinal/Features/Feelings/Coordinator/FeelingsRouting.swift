//
//  FeelingsRouting.swift
//  ChallengeFinal
//
//  Created by Paulo Henrique Costa Alves on 02/11/26.
//

import Foundation
import SwiftData

/// O que quem usa o Coordinator de Feelings enxerga dele.
protocol FeelingsRouting {
    /// View já montada, para ser reaproveitada.
    var cached: FeelingsView? { get set }
    
    /// Devolve a view de Feelings (montando pelo Builder se ainda não existir).
    func startFeelingsView(context: ModelContext) -> FeelingsView
}
