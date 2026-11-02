//
//  FeelingsRouting.swift
//  ChallengeFinal
//
//  Created by Paulo Henrique Costa Alves on 02/11/26.
//

import Foundation
import SwiftData

protocol FeelingsRouting {
    var cached: FeelingsView? { get set }
    
    func startFeelingsView(context: ModelContext) -> FeelingsView
}
