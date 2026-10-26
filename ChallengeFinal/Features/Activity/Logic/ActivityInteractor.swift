//
//  ActivityInteractor.swift
//  ChallengeFinal
//
//  Created by Raquel Souza on 19/10/26.
//

import Foundation
import SwiftUI
import PhotosUI

// MARK: - Protocol

/// O que as Views enxergam do Interactor: só as AÇÕES que o usuário pode fazer.
///
/// Com o protocolo, a View não depende da classe concreta. Nos testes e nos
/// `#Preview`, dá para passar um Interactor falso que só anota os toques.
@MainActor
protocol ActivityInteractorProtocol: AnyObject {

    // MARK: Step .photo (implementados em ActivityInteractor+Photo.swift)
    func openCamera()
    func retakePhoto()
    func closeCamera()
    func toggleFlash()
    func switchCamera()
    func takePhoto()
    func didSelectFromGallery(_ item: PhotosPickerItem)
    func continueFromPhoto()
    func dismissAlerts()

    // MARK: Outros steps (ainda placeholders)
    func drawChallenge()
    func acceptChallenge()
    func completeChallenge()
    func selectMood()
    func finish()
}

// MARK: - Class

/// O "cérebro" do fluxo de Activity.
///
/// Decide o que acontece em cada ação do usuário, guarda os dados do fluxo
/// (desafio, humor, foto, tempo...), usa os Workers para o trabalho pesado,
/// avisa o Presenter do resultado e chama o Routing quando um step termina.
///
/// Organização:
/// - Este arquivo: dependências, dados do fluxo e init.
/// - `ActivityInteractor+Photo.swift`: ações do step `.photo`.
/// - Os outros steps ganham as próprias extensions (`+Draw`, `+Mood`...).
///
/// As propriedades não são `private` porque as extensions ficam em outros
/// arquivos e precisam acessá-las. Mesmo assim, só o Interactor deve alterá-las.
@MainActor
final class ActivityInteractor: ActivityInteractorProtocol {

    // MARK: - Dependências

    /// Para quem o Interactor manda os resultados. Pelo protocolo, para dar spy nos testes.
    let presenter: ActivityPresenterProtocol

    /// Para quem avisamos que um step terminou. `weak` porque o Coordinator
    /// é quem "segura" o fluxo; se fosse forte, criaria um ciclo de memória.
    weak var routing: ActivityRouting?

    /// A câmera. Pelo protocolo, para dar mock nos testes.
    let camera: CameraWorking

    // MARK: - Dados do fluxo

    /// Foto escolhida no step `.photo` (câmera ou galeria).
    /// `nil` = o usuário continuou sem foto. Vai para o `ActivityResult` no final.
    var selectedPhoto: Data?

    /// Se o flash está ligado na tela da câmera.
    var isFlashOn = false

    // MARK: - Init

    init(presenter: ActivityPresenterProtocol,
         routing: ActivityRouting,
         camera: CameraWorking) {
        self.presenter = presenter
        self.routing = routing
        self.camera = camera
    }

    deinit {
        print("ActivityInteractor liberado")
    }

    // MARK: - Outros steps (ainda como estavam)
    // Quando cada step for implementado, mova o método para a extension dele.

    func drawChallenge() {
        //CHANGE
        routing?.didDraw()
    }

    func acceptChallenge() {
        routing?.didAcceptChallenge()
    }

    func completeChallenge() {
        //CHANGE
        routing?.didCompleteChallenge()
    }

    func selectMood() {
        //CHANGE
        routing?.didSelectMood()
    }

    func finish() {
        //CHANGE
        // só avisa o coordinator se salvar com sucesso
        routing?.didFinishChallenge()
    }
}
