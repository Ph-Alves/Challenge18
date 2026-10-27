//
//  ActivityInteractor.swift
//  ChallengeFinal
//
//  Created by Raquel Souza on 19/10/26.
//

import Foundation
import FoundationModels
import PhotosUI
import SwiftUI

// MARK: - Protocol

/// O que as Views enxergam do Interactor: só as AÇÕES que o usuário pode fazer.
///
/// Com o protocolo, a View não depende da classe concreta. Nos testes e nos
/// `#Preview`, dá para passar um Interactor falso que só anota os toques.
protocol ActivityInteractorProtocol: AnyObject {
    // MARK: - Step do cronometro
    func startTimer()
    func stopTimer()
    func cancelTimer()
    
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
    
    // MARK: Navigation
    func acceptChallenge()
    func startChallenge()
    func goToActivityDetail()
    func returnToStart()
    func finishActivity()
}

// MARK: - Class

/// O "cérebro" do fluxo de Activity.
///
/// Decide o que acontece em cada ação do usuário, guarda os dados do fluxo
/// (desafio, humor, foto, tempo...), usa os Workers para o trabalho pesado
/// e avisa o Presenter do resultado. A navegação entre steps passa pelo
/// Presenter -> Store -> Coordinator.
///
/// Organização:
/// - Este arquivo: dependências, dados do fluxo e init.
/// - `ActivityInteractor+Photo.swift`: ações do step `.photo`.
/// - Os outros steps ganham as próprias extensions (`+Draw`, `+Mood`...).
///
/// As propriedades usadas pelas extensions não são `private` porque elas
/// ficam em outros arquivos. Mesmo assim, só o Interactor deve alterá-las.
@MainActor
final class ActivityInteractor: ActivityInteractorProtocol {
    
    // MARK: - Dependências
    
    /// Para quem o Interactor manda os resultados. Pelo protocolo, para dar spy nos testes.
    let presenter: ActivityPresenterProtocol
    
    /// A câmera. Pelo protocolo, para dar mock nos testes.
    let camera: CameraWorkerProtocol
    
    private let activityRepository: GenericRepository<Activity>
    
    private var hapticWorker: HapticsWorkerProtocol
    
    private var coreMotionWorker: CoreMotionWorkerProtocol
    /// Worker responsável pelas operações do foundation
    private var foundationWorker: FoundationWorkerProtocol

    /// O cronometro utilizando protocolo
    let timer: TimerWorkerProtocol
    
    // MARK: - Dados do fluxo
    
    /// Foto escolhida no step `.photo` (câmera ou galeria).
    /// `nil` = o usuário continuou sem foto. Vai para o `ActivityResult` no final.
    var selectedPhoto: Data?
    
    /// Se o flash está ligado na tela da câmera.
    var isFlashOn = false
    
    /// Quando o timer foi inciado
    var timerStartDate: Date?
    
    /// O tempo que se passounem segundos
    var timerElapsed: TimeInterval = 0
    
    /// Variável que guarda o Task de timer
    var timerTask: Task<Void, Never>?

    private var shakeWasStrongEnough = false
    private var shakeIdleTimer: Timer?
    private let motionFeedbackThreshold: Double = 0.3
    private var isRaffling: Bool = false
    
    // MARK: - Init
    
    init(presenter: ActivityPresenterProtocol,
         activityRepository: GenericRepository<Activity>,
         hapticWorker: HapticsWorkerProtocol,
         coreMotionWorker: CoreMotionWorkerProtocol,
         foundationWorker: FoundationWorkerProtocol,
         camera: CameraWorkerProtocol, 
         timer: TimerWorkerProtocol) {
        self.presenter = presenter
        self.activityRepository = activityRepository
        self.hapticWorker = hapticWorker
        self.coreMotionWorker = coreMotionWorker
        self.foundationWorker = foundationWorker
        self.camera = camera
        self.timer = timer
    }
    
    // MARK: - Navigation
    //
    // Por enquanto só pedem ao Presenter para trocar de step.
    // A regra de cada step (sorteio, tempo, humor...) entra nas próximas extensions.
    
    /// Aceitou o desafio sorteado: vai para "em andamento".
    func acceptChallenge() {
        presenter.presentInProgress()
    }
    
    /// Começou a executar o desafio: também vai para "em andamento".
    func startChallenge() {
        presenter.presentInProgress()
    }
    
    /// Abre os detalhes do desafio.
    func goToActivityDetail() {
        presenter.presentChallenge()
    }
    
    /// Volta para o sorteio.
    func returnToStart() {
        presenter.presentDraw()
    }
    
    /// Termina o fluxo e volta para a Home.
    func finishActivity() {
        presenter.presentFlowFinished()
    }
}
