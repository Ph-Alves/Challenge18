//
//  ChallengesStore.swift
//  ChallengeFinal
//
//  Created by Raquel Souza on 03/11/26.
//

import Foundation

// MARK: - Protocol
// O que o Presenter enxerga da Store.
@MainActor
protocol ChallengesStoreProtocol: AnyObject {
    func displayChallenges(_ challenges: [Activity], selectedCategory: ActivityCategory?, emptyState: ChallengesEmptyState?) //quem decide qual estado vazio mostrar é o Presenter, e a Store só guarda o que recebe, e um estado vazio pode ser ou de não ter nada ou de não ter achado nada na busca.
    func displayArchivedChallenges(_ challenges: [Activity], emptyState: ChallengesEmptyState?) //lista de conteúdos dentro da sheet
    func displayArchivedSheet(isPresented: Bool) //bool pra ativar a sheet.
    func displaySummary(_ activity: Activity)
    func displayError(_ message: String?)
}

// MARK: - Class
// Estado da aba Desafios. A View só LÊ daqui; quem escreve é o Presenter.
// Também repassa a navegação ao Coordinator.
@MainActor
@Observable
final class ChallengesStore: ChallengesStoreProtocol {

    // MARK: - Variables
    let coordinator: ChallengesRouting

    // Listagem
    /// Desafios concluídos, já filtrados e ordenados pelo Interactor.
    private(set) var challenges: [Activity] = []
    
    /// Filtro ativo. `nil` = todas as categorias.
    private(set) var selectedCategory: ActivityCategory?
    
    /// `nil` = tem desafios para mostrar.
    private(set) var emptyState: ChallengesEmptyState?

    // Arquivados (sheet)
    private(set) var archivedChallenges: [Activity] = []
    private(set) var archivedEmptyState: ChallengesEmptyState?
    private(set) var isArchivedPresented = false

    // Erro. `nil` = sem alerta.
    private(set) var errorMessage: String?

    // MARK: - Init
    init(coordinator: ChallengesRouting) {
        self.coordinator = coordinator
    }

    // MARK: - Funções do ciclo VIP

    func displayChallenges(_ challenges: [Activity], selectedCategory: ActivityCategory?, emptyState: ChallengesEmptyState?) {
        self.challenges = challenges
        self.selectedCategory = selectedCategory
        self.emptyState = emptyState
    }

    func displayArchivedChallenges(_ challenges: [Activity], emptyState: ChallengesEmptyState?) {
        self.archivedChallenges = challenges
        self.archivedEmptyState = emptyState
    }

    func displayArchivedSheet(isPresented: Bool) {
        self.isArchivedPresented = isPresented
    }

    func displayError(_ message: String?) {
        self.errorMessage = message
    }

    // MARK: - Navigation

    func displaySummary(_ activity: Activity) {
        coordinator.showSummary(activity)
    }
}

