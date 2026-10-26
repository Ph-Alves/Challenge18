//
//  HomeRouting.swift
//  ChallengeFinal
//
//  Created by Raquel Souza on 19/10/26.
//

import Foundation
import SwiftData

// MARK: - Protocol
// Protocolo do Coordinator
@MainActor
protocol HomeRouting: AnyObject {
    var cached: HomeView? { get set }
    var step: HomeStep { get }
    
    func startHomeFlow(context: ModelContext) -> HomeView
    func startActivityFlow(category: ActivityCategory)
}
