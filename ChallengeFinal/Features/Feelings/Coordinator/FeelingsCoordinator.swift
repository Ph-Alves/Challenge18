//
//  FeelingsCoordinator.swift
//  ChallengeFinal
//
//  Created by Paulo Henrique Costa Alves on 02/11/26.
//

import Foundation
import SwiftData

@MainActor
final class FeelingsCoordinator: FeelingsRouting {
    
    var cached: FeelingsSummaryView?
    
    init(cached: FeelingsSummaryView? = nil) {
        self.cached = cached
    }
    
    func startFeelingsView(context: ModelContext) -> FeelingsSummaryView {
        if let cached {
            return cached
        }
        
        let view = FeelingsBuilder.build()
        cached = view
        return view
    }
}
