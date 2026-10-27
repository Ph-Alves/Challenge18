//
//  HomeRouting.swift
//  ChallengeFinal
//
//  Created by Raquel Souza on 19/10/26.
//

import Foundation
import SwiftData

// MARK: - Protocol
// O que a Store enxerga do Coordinator: só navegação.
// Assim a Store não depende da classe concreta e dá para trocar por um fake nos testes.
@MainActor
protocol HomeRouting: AnyObject {
    // View já montada (evita recriar a Home a cada render)
    var cached: HomeView? { get set }
    // Em qual tela do fluxo estamos (Home ou Activity)
    var step: HomeStep { get }
    
    // Monta (ou devolve do cache) a view da Home
    func startHomeFlow(context: ModelContext) -> HomeView
    // Abre o fluxo de Activity já com a categoria escolhida na Home
    func startActivityFlow(category: ActivityCategory)
}
