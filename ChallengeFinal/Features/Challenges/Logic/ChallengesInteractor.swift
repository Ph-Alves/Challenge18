//
//  ChallengesInteractor.swift
//  ChallengeFinal
//
//  Created by Raquel Souza on 03/11/26.
//

import Foundation

protocol ChallengesInteractorProtocol: AnyObject {
    func loadChallenges()                             // tela apareceu: busca concluídos e arquivados
    func search(_ text: String)                       // digitou na busca
    func toggleCategory(_ category: ActivityCategory) // tocou num filtro (toca de novo para limpar)
    func openArchived()                               // botão de arquivados
    func closeArchived()                              // fechou o sheet (X ou arrastando)
    func restoreChallenge(_ activity: Activity)       // devolver o arquivado ao grupo
    func openSummary(_ activity: Activity)            // tocou num card: abre o resumo
    func closeSummary()                               //fechou o sheet de summary
    func dismissError()                               // fechou o alerta de erro
}

//MARK: - Class
final class ChallengesInteractor: ChallengesInteractorProtocol {
    
    // MARK: - Variables
    private let repository: GenericRepository<Activity>
    private let presenter: ChallengesPresenterProtocol
    
    ///Estado dos filtros: guardado aqui para que, ao voltar para a tela (ou devolver um arquivado), a lista recalcule com os mesmos critérios.
    private(set) var searchText: String = ""
    private(set) var selectedCategory: ActivityCategory?
    
    // MARK: - Init
    init(repository: GenericRepository<Activity>, presenter: ChallengesPresenterProtocol) {
        self.repository = repository
        self.presenter = presenter
    }
    
    //MARK: - Functions
    
    func loadChallenges() {
        refreshCompleted()
        refreshArchived()
    }
    
    func search(_ text: String) {
        searchText = text
        refreshCompleted()
    }
    
    func toggleCategory(_ category: ActivityCategory) {
        selectedCategory = (selectedCategory == category) ? nil : category
        refreshCompleted()
    }
    
    func openArchived() {
        refreshArchived()
        presenter.presentArchivedSheet(isPresented: true)
    }
    
    func closeArchived() {
        presenter.presentArchivedSheet(isPresented: false)
    }
    
    ///lembrando que aqui nessa função eu to tirando a activity dos arquivados
    func restoreChallenge(_ activity: Activity) {
        guard activity.archived else { return }

        do {
            activity.archived = false
            try repository.save()
        } catch {
            presenter.presentError("não foi possível devolver o desafio. tente de novo.")
        }
        refreshArchived()
    }
    
    func openSummary(_ activity: Activity) {
        presenter.presentSummary(activity)
    }
    
    func closeSummary() {
        presenter.presentSummary(nil)
    }
    
    func dismissError() {
        presenter.presentError(nil)
    }
    
    //MARK: - Private Functions
    
    ///a primeira função será a de carregar os challenges já feitos.
    private func completedActivities() throws -> [Activity] {
        try repository.getAll()
            .filter { !$0.archived && $0.result != nil } //pegar tudo o que nao estiver arquivado e tudo o que for diferente de nil
//            .sorted { $0.createdAt > $1.createdAt } //CHANGE: descomentar após o ph inserir a data de criação na model
    }
    
    private func refreshCompleted() {
        do {
            let completed = try completedActivities()
            let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)

            let filtered = completed
                .filter { selectedCategory == nil || $0.category == selectedCategory }
                // Ignora maiúsculas e acentos
                .filter { query.isEmpty || $0.name.localizedStandardContains(query) }

            presenter.presentChallenges(filtered, selectedCategory: selectedCategory,hasCompletedChallenges: !completed.isEmpty)
        } catch {
            presenter.presentError("não foi possível carregar seus desafios.")
        }
    }
    
    
    private func refreshArchived() {
        do {
            let archived = try repository.getAll()
                .filter(\.archived)
//                .sorted { $0.createdAt > $1.createdAt } //CHANGE: descomentar após o ph inserir a data de criação na model
            presenter.presentArchivedChallenges(archived)
        } catch {
            presenter.presentError("não foi possível carregar os arquivados.")
        }
    }
    
}
