//
//  ChallengesPresenter.swift
//  ChallengeFinal
//
//  Created by Raquel Souza on 03/11/26.
//

import SwiftUI

// MARK: - Protocol
// O que o Interactor enxerga do Presenter.
@MainActor
protocol ChallengesPresenterProtocol: AnyObject {
    func presentChallenges(_ activities: [Activity], selectedCategory: ActivityCategory?, hasCompletedChallenges: Bool)
    func presentArchivedChallenges(_ activities: [Activity])
    func presentArchivedSheet(isPresented: Bool)
    func presentSummary(_ activity: Activity?) // `nil` = fecha o sheet do resumo
    func presentShareSheet(fileURL: URL)
    func presentShareFinished(completed: Bool)
    func presentError(_ message: String?)
}

// MARK: - Class
// "Tradutor" da aba Desafios. `Activity` vão direto para a Store; aqui só se decide COMO mostrar (qual estado vazio usar).
@MainActor
final class ChallengesPresenter: ChallengesPresenterProtocol {

    // MARK: - Variables
    weak var store: ChallengesStoreProtocol?

    // MARK: - Init
    init(store: ChallengesStoreProtocol) {
        self.store = store
    }

    // MARK: - Listagem

    func presentChallenges(_ activities: [Activity], selectedCategory: ActivityCategory?, hasCompletedChallenges: Bool) {
        let emptyState: ChallengesEmptyState?
        if !activities.isEmpty {
            emptyState = nil
        } else {
            // Tem desafios concluídos mas nada bateu = busca/filtro sem resultado.
            emptyState = hasCompletedChallenges ? .noResults : .noCompleted
        }

        store?.displayChallenges(activities, selectedCategory: selectedCategory, emptyState: emptyState)
    }

    // MARK: - Arquivados

    func presentArchivedChallenges(_ activities: [Activity]) {
        store?.displayArchivedChallenges(activities, emptyState: activities.isEmpty ? .noArchived : nil)
    }

    func presentArchivedSheet(isPresented: Bool) {
        store?.displayArchivedSheet(isPresented: isPresented)
    }

    // MARK: - Resumo

    func presentSummary(_ activity: Activity?) {
        guard let activity else {
            store?.displaySummary(nil, photo: nil)
            store?.displayShareSheet(nil)
            return
        }
        // Bytes -> Image: a View recebe a foto pronta para exibir.
        store?.displaySummary(activity, photo: Image(data: activity.result?.photo))
    }

    // MARK: - Compartilhar
 
    func presentShareSheet(fileURL: URL) {
        store?.displayShareSheet(ShareItem(activityItems: [fileURL]))
    }
 
    func presentShareFinished(completed: Bool) {
        store?.displayShareSheet(nil)
    }
    
    //MARK: - Erros
 
    func presentError(_ message: String?) {
        store?.displayError(message)
    }
    
}
