//
//  ChallengePresenter.swift
//  ChallengeFinal
//
//  Created by Raquel Souza on 19/10/26.
//

import Foundation
import SwiftUI

// MARK: - Protocol
/// O que o Interactor enxerga do Presenter.
///
/// Com o protocolo, nos testes do Interactor dá para usar um *spy*
/// (um Presenter falso que só anota o que foi chamado), sem Store nem View.
protocol ActivityPresenterProtocol: AnyObject {
    // MARK: -  Step do cronometro
    func presentTime(_ elapsed: TimeInterval)
    
    // MARK: Steps .draw e .challenge (implementados em ActivityPresenter+Draw.swift)
    func presentActivity(_ challenge: FrictionChallenge)
    func presentSearching()
    func presentSearchFailed()
    func presentAcceptedActivity()
    func presentStartAgain()
    func presentMood()
    func presentPhoto()
    
    // MARK: Step .photo
    func presentCamera()
    func presentCameraClosed()
    func presentPermissionDenied()
    func presentCaptured(_ data: Data)
    func presentFlash(isOn: Bool)
    func presentError(_ error: Error)
    func presentAlertsDismissed()
    
    // MARK: Navigation
    func presentSummary()
    func presentFlowFinished()
    func presentInProgress()
    func presentActivityStep()
    func presentDraw()
}

// MARK: - Class
/// O "tradutor" do fluxo de Activity.
///
/// Recebe dados crus do Interactor (`Data`, `Bool`, `Error`), transforma em
/// coisas prontas para a tela (`Image`, textos, ícones) e entrega para a Store
/// pelos métodos `display...`.
///
/// Regras:
/// - Não chama Interactor, Worker nem Coordinator.
/// - Não decide regra de negócio (isso é do Interactor), só COMO mostrar.
/// - Só conhece a Store pelo `ActivityStoreProtocol`.
@MainActor
final class ActivityPresenter: ActivityPresenterProtocol {
   
    
    
    
    
    // MARK: - Variables
    /// Não é `private` porque `ActivityPresenter+Draw.swift` também usa.
    weak var store: ActivityStoreProtocol?
    
    // MARK: - Init
    init(store: ActivityStoreProtocol) {
        self.store = store
    }
    
    // MARK: - Functions
    
    // MARK: Step .photo

    /// Permissão OK: abre a tela da câmera.
    func presentCamera() {
        store?.displayPermissionAlert(nil)
        store?.displayError(nil)
        store?.displayCamera(isPresented: true)
    }

    /// Fecha a tela da câmera (cancelou ou terminou).
    func presentCameraClosed() {
        store?.displayCamera(isPresented: false)
    }

    /// Permissão negada: a câmera não abre e mostramos o alerta.
    func presentPermissionDenied() {
        store?.displayCamera(isPresented: false)
        store?.displayPermissionAlert(
            "Para tirar sua foto, libere o acesso à câmera nos Ajustes. Você também pode importar da galeria ou continuar sem foto."
        )
    }

    /// Chegou uma foto (da câmera ou da galeria).
    ///
    /// `Data` (bytes) -> `UIImage` -> `Image` (SwiftUI),
    /// e os textos dos botões passam para o estado "com foto".
    func presentCaptured(_ data: Data) {
        guard let uiImage = UIImage(data: data) else {
            // Os bytes não formam uma imagem válida.
            store?.displayCamera(isPresented: false)
            store?.displayError("Não foi possível carregar a foto. Tente novamente.")
            return
        }
        store?.displayPhoto(Image(uiImage: uiImage))
        store?.displayError(nil)
        store?.displayCamera(isPresented: false)
    }

    /// Atualiza o ícone do botão de flash na câmera.
    func presentFlash(isOn: Bool) {
        store?.displayFlashIcon(isOn ? "bolt.fill" : "bolt.slash")
    }

    /// Transforma um erro técnico numa mensagem para o usuário.
    /// O Interactor só repassa o erro; escolher o texto é papel do Presenter.
    func presentError(_ error: Error) {
        let message: String

        switch error {
        case CameraError.deviceUnavailable:
            message = "Não encontramos uma câmera neste aparelho. Você pode importar da galeria."
        case CameraError.captureInProgress:
            // Toque duplo no disparo: não é um problema para o usuário, só ignoramos.
            return
        case CameraError.sessionNotRunning,
             CameraError.configurationFailed:
            message = "A câmera não está pronta. Feche e tente novamente."
        case CameraError.captureFailed:
            message = "Não foi possível tirar a foto. Tente novamente."
        case PhotoLibraryError.loadFailed:
            message = "Não foi possível carregar a foto da galeria. Tente outra."
        default:
            message = "Algo deu errado. Tente novamente."
        }

        store?.displayError(message)
    }

    /// O usuário fechou o alerta (de permissão ou de erro).
    func presentAlertsDismissed() {
        store?.displayPermissionAlert(nil)
        store?.displayError(nil)
    }
    
    // MARK: - Step do cronometro
    /// Recebe o tempo em segundos e entrega o texto "hh:mm:ss" para a Store.
    /// Formatar é papel do Presenter: o Interactor nunca monta texto de tela.
    /// Ex.: 3725s = 1h 02min 05s -> "01:02:05" (`%02d` completa com zero à esquerda).
    func presentTime(_ elapsed: TimeInterval) {
        let total = Int(elapsed)
        let hours = total / 3600
        let minutes = (total % 3600) / 60
        let seconds = total % 60
        store?.displayTimer(String(format: "%02d:%02d:%02d", hours, minutes, seconds))
    }
    
    // MARK: Navigation
    // Não há o que formatar: só traduz "apresentar X" em "transicionar para X" na Store.
    func presentSummary() {
        store?.transitionToSummary()
    }
    
    func presentFlowFinished() {
        store?.finishFlow()
    }
    
    func presentInProgress() {
        store?.transitionToInProgress()
    }
    
    func presentActivityStep() {
        store?.transitionToActivity()
    }
    
    func presentDraw() {
        store?.transitionToDraw()
    }
}
