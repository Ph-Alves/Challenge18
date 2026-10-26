//
//  ChallengePresenter.swift
//  ChallengeFinal
//
//  Created by Raquel Souza on 19/10/26.
//

import SwiftUI

/// O que o Interactor enxerga do Presenter.
///
/// Com o protocolo, nos testes do Interactor dá para usar um *spy*
/// (um Presenter falso que só anota o que foi chamado), sem Store nem View.
@MainActor
protocol ActivityPresenterProtocol: AnyObject {

    // MARK: Step .photo
    func presentCamera()
    func presentCameraClosed()
    func presentPermissionDenied()
    func presentCaptured(_ data: Data)
    func presentFlash(isOn: Bool)
    func presentError(_ error: Error)
    func presentAlertsDismissed()
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

    /// Quem segura a Store de verdade é a View. Se ninguém segurar,
    /// ela vira `nil` e o Presenter para de escrever, sem crashar.
    weak var store: ActivityStoreProtocol?

    // MARK: - Init

    init(store: ActivityStoreProtocol) {
        self.store = store
    }

    deinit {
        print("ActivityPresenter liberado")
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

    // MARK: Outros steps
}
