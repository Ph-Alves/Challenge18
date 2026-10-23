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
    func startChallengeFlow()
    func startHome(context: ModelContext) -> HomeView
}
