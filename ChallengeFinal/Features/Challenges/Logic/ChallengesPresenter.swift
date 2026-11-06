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
    // Câmera
    func presentCamera(isPresented: Bool)
    func presentCameraClosed()
    func presentPermissionDenied()
    func presentFlash(isOn: Bool)
    func presentCameraError(_ error: Error)
    // Reflita
    func presentHumor(_ humor: Humor)
    func presentMood(isPresented: Bool)
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
    
    // MARK: - Câmera (tirar outra foto)
 
    func presentCamera(isPresented: Bool) {
        if isPresented { store?.displayError(nil) }
        store?.displayCamera(isPresented: isPresented)
    }
 
    /// Fecha a tela da câmera (cancelou ou terminou).
    func presentCameraClosed() {
        store?.displayCamera(isPresented: false)
    }
 
    /// Permissão negada: a câmera não abre e mostramos o alerta (dentro do resumo, que continua aberto).
    func presentPermissionDenied() {
        store?.displayCamera(isPresented: false)
        store?.displayError("para tirar sua foto, libere o acesso à câmera nos ajustes. você também pode importar da galeria.")
    }
 
    /// Atualiza o ícone do botão de flash na câmera.
    func presentFlash(isOn: Bool) {
        store?.displayCameraFlashIcon(isOn ? "bolt.fill" : "bolt.slash")
    }
 
    /// Transforma um erro técnico da câmera/galeria numa mensagem para o usuário.
    func presentCameraError(_ error: Error) {
        let message: String
 
        switch error {
        case CameraError.deviceUnavailable:
            message = "não encontramos uma câmera neste aparelho. você pode importar da galeria."
        case CameraError.captureInProgress:
            // Toque duplo no disparo: não é um problema para o usuário, só ignoramos.
            return
        case CameraError.sessionNotRunning,
             CameraError.configurationFailed:
            message = "a câmera não está pronta. feche e tente de novo."
        case CameraError.captureFailed:
            message = "não foi possível tirar a foto. tente de novo."
        case PhotoLibraryError.loadFailed:
            message = "não foi possível carregar a foto da galeria. tente outra."
        default:
            message = "algo deu errado. tente de novo."
        }
 
        store?.displayError(message)
    }
    
    // MARK: - Reflita (humor)
    
    func presentHumor(_ humor: Humor) {
        store?.displayHumor(humor)
    }
    
    func presentMood(isPresented: Bool) {
        store?.displayMood(isPresented: isPresented)
    }
}
