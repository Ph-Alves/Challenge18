//
//  HomeStore.swift
//  ChallengeFinal
//
//  Created by Paulo Henrique Costa Alves on 21/10/26.
//

import Foundation
import SwiftUI

// MARK: - Protocol
@MainActor
protocol HomeStoreProtocol: AnyObject {
    func displayCategory(_ current: ActivityCategory) // Mostrar a categoria para a view
    func displayWeek(days: [String]) // Salvar a semana que vai ser mostrada
    func displayActivityFlow()
}

// MARK: - Class
// Main actor aqui é necessário por que estamos trabalhando com uma classe que age diretamente com a view
// então deve rodar na thread principal
// as outras classes vão ser @MainActor por efeito cascata.
@MainActor
@Observable
final class HomeStore: HomeStoreProtocol {
    // MARK: - Variables
    
    // Recebe o coordinator (vai disparar os fluxos novos)
    var coordinator: HomeRouting
    
    // Dados da view
    private(set) var currentCategory: ActivityCategory = .physical // categoria atual
    var daysOfWeek: [String] = [] // Dias da semana atual
    
    // MARK: - Init
    init(coordinator: HomeRouting) {
        self.coordinator = coordinator
    }
    
    // MARK: - Navigation Functions
    
    func displayActivityFlow() {
        self.coordinator.startActivityFlow(category: currentCategory)
    }
    
    // MARK: - Funções do ciclo VIP
    
    func displayCategory(_ category: ActivityCategory) {
        self.currentCategory = category
    }
    
    func displayWeek(days: [String]) {
        self.daysOfWeek = days
    }
}
