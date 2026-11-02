//
//  FeelingsBuilder.swift
//  ChallengeFinal
//
//  Created by Paulo Henrique Costa Alves on 02/11/26.
//

import Foundation

enum FeelingsBuilder {
        
    @MainActor
    static func build() -> FeelingsSummaryView {
        
        
        return FeelingsSummaryView(fraction: 0.0, icon: "", count: 0)
    }
}
