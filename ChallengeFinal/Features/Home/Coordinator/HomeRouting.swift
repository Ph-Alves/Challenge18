//
//  HomeRouting.swift
//  ChallengeFinal
//
//  Created by Raquel Souza on 19/10/26.
//

import Foundation
import SwiftData

@MainActor
protocol HomeRouting: AnyObject {
    func startChallengeFlow()
    func startHome(context: ModelContext) -> HomeView
}
