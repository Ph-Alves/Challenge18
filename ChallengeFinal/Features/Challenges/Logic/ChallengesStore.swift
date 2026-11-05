//
//  ChallengesStore.swift
//  ChallengeFinal
//
//  Created by Raquel Souza on 03/11/26.
//

import SwiftUI

// MARK: - Protocol
// O que o Presenter enxerga da Store.
@MainActor
protocol ChallengesStoreProtocol: AnyObject {
    func displayChallenges(_ challenges: [Activity], selectedCategory: ActivityCategory?, emptyState: ChallengesEmptyState?) //quem decide qual estado vazio mostrar é o Presenter, e a Store só guarda o que recebe, e um estado vazio pode ser ou de não ter nada ou de não ter achado nada na busca.
    func displayArchivedChallenges(_ challenges: [Activity], emptyState: ChallengesEmptyState?) //lista de conteúdos dentro da sheet
    func displayArchivedSheet(isPresented: Bool) //bool pra ativar a sheet.
    func displaySummary(_ activity: Activity?, photo: Image?)
    func displayShareSheet(_ item: ShareItem?)
    func displayError(_ message: String?)
    // MARK: Câmera
    func displayCamera(isPresented: Bool)
    func displayCameraFlashIcon(_ icon: String)
}

// MARK: - Class
// Estado da aba Desafios. A View só LÊ daqui; quem escreve é o Presenter.
// Também repassa a navegação ao Coordinator.
@MainActor
@Observable
final class ChallengesStore: ChallengesStoreProtocol {

    // MARK: - Variables

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
    
    //Summary. Desafio aberto no resumo. `nil` = sheet fechada.
    private(set) var selectedChallenge: Activity?
    
    /// Foto do desafio aberto, já pronta para exibir. `nil` = card vazio.
    private(set) var selectedPhoto: Image?
    
    // Compartilhar
    /// Controla o `.sheet(item:)` do share sheet. `nil` = fechado.
    private(set) var shareItem: ShareItem?

    // Erro. `nil` = sem alerta.
    private(set) var errorMessage: String?
    
    // Câmera (tirar outra foto no resumo)
    private(set) var isCameraPresented = false
    private(set) var cameraFlashIcon = "bolt.slash"

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
    
    
    func displaySummary(_ activity: Activity?, photo: Image?) {
        selectedChallenge = activity
        selectedPhoto = photo
    }
    
    func displayShareSheet(_ item: ShareItem?) {
        shareItem = item
    }

    func displayError(_ message: String?) {
        self.errorMessage = message
    }
    
    func displayCamera(isPresented: Bool) {
        isCameraPresented = isPresented
    }
    
    func displayCameraFlashIcon(_ icon: String) {
        cameraFlashIcon = icon
    }
}

// MARK: - Estados vazios da aba Desafios
// O Presenter decide QUAL estado mostrar; os textos ficam aqui.
// Não é dado do banco: é só o que a tela mostra quando não há o que listar.
enum ChallengesEmptyState: Equatable {
    case noCompleted   // ainda não concluiu nenhum desafio
    case noResults     // tem desafios, mas a busca/filtro não encontrou nenhum
    case noArchived    // nenhum desafio arquivado

    var title: String {
        switch self {
        case .noCompleted: "nenhum desafio concluído"
        case .noResults: "nenhum desafio encontrado"
        case .noArchived: "nada arquivado por aqui"
        }
    }

    var message: String {
        switch self {
        case .noCompleted: "procure um novo desafio na home :)"
        case .noResults: "tente buscar por outro título ou trocar a categoria."
        case .noArchived: "quando você arquivar um desafio no sorteio, ele aparece nesta lista."
        }
    }
}
