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
    
    var cached: FeelingsView?
    
    init(cached: FeelingsView? = nil) {
        self.cached = cached
    }
    
    func startFeelingsView(context: ModelContext) -> FeelingsView {
        if let cached {
            return cached
        }
        
        let view = FeelingsBuilder.build(context: context)
        cached = view
        return view
    }
}
