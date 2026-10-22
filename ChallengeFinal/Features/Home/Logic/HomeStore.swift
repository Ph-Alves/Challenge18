//
//  HomeStore.swift
//  ChallengeFinal
//
//  Created by Paulo Henrique Costa Alves on 21/10/26.
//

import Foundation
import SwiftUI

protocol HomeStoreProtocol: AnyObject {
    func displayCategory(_ current: ActivityCategory)
    func displayWeek(days: [String])
}

@MainActor
@Observable
final class HomeStore: HomeStoreProtocol {
    
    var coordinator: HomeRouting
    
    private(set) var currentCategory: ActivityCategory = .physical
    var daysOfWeek: [String] = []
    
    init(coordinator: HomeRouting) {
        self.coordinator = coordinator
    }
    
    func displayCategory(_ category: ActivityCategory) {
        self.currentCategory = category
    }
    
    func displayWeek(days: [String]) {
        self.daysOfWeek = days
    }
}
