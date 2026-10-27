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
    // MARK: Step .inProgress (implementados em ActivityInteractor+Timer.swift)
    func startTimer()
    func stopTimer()
    func cancelTimer()
    
    // MARK: Step .draw (implementados em ActivityInteractor+Draw.swift)
    func detectMotion(for category: ActivityCategory)
    func finishDetection()
    func prepare(for category: ActivityCategory)
    func archiveActivity(title: String, description: String, in category: ActivityCategory)
    func reroll(for category: ActivityCategory)
    func raffle(for category: ActivityCategory)
    
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
    func acceptActivity()
    func startActivity()
    func goToActivityDetail()
    func returnToStart()
    func completeActivity()
    func selectMood()
    func finishActivityFlow()
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
    
    let activityRepository: GenericRepository<Activity>
    
    var hapticWorker: HapticsWorkerProtocol
    
    var coreMotionWorker: CoreMotionWorkerProtocol
    /// Worker responsável pelas operações do foundation
    var foundationWorker: FoundationWorkerProtocol

    /// O cronômetro: só entrega os ticks de 1 segundo. Pelo protocolo, para dar mock nos testes.
    let timer: TimerWorkerProtocol
    
    /// A Live Activity (Dynamic Island) do cronômetro. Pelo protocolo, para dar mock nos testes.
    /// Quem fala com ela é o Interactor direto, sem passar pelo Presenter: é algo do sistema,
    /// não da tela do app.
    let liveActivity: WidgetWorkerProtocol
    
    // MARK: - Dados do fluxo
    
    /// Foto escolhida no step `.photo` (câmera ou galeria).
    /// `nil` = o usuário continuou sem foto. Vai para o `ActivityResult` no final.
    var selectedPhoto: Data?
    
    /// Se o flash está ligado na tela da câmera.
    var isFlashOn = false
    
    /// Quando o cronômetro foi iniciado. `nil` = parado.
    /// O tempo é sempre calculado a partir desta data, nunca contado de 1 em 1.
    var timerStartDate: Date?
    
    /// Tempo final da atividade, em segundos, fixado ao terminar (`stopTimer`).
    /// Vai para o `ActivityResult` no final. Volta a 0 se o usuário cancelar.
    var timerElapsed: TimeInterval = 0
    
    /// O Task que escuta os ticks do worker. Fica guardado para poder ser cancelado.
    var timerTask: Task<Void, Never>?

    /// Grupo da atividade (mente, movimento, sentidos ou conexão), escolhido na Home.
    /// Não muda durante o fluxo, por isso entra no init em vez de ser passado a cada ação.
    /// Aparece na Live Activity.
    let category: ActivityCategory


    // Estado do sorteio (usado em ActivityInteractor+Draw.swift)
    var shakeWasStrongEnough = false
    var shakeIdleTimer: Timer?
    let motionFeedbackThreshold: Double = 0.3
    var isRaffling: Bool = false
    
    // MARK: - Init
    
    init(presenter: ActivityPresenterProtocol,
         activityRepository: GenericRepository<Activity>,
         hapticWorker: HapticsWorkerProtocol,
         coreMotionWorker: CoreMotionWorkerProtocol,
         foundationWorker: FoundationWorkerProtocol,
         camera: CameraWorkerProtocol, 
         timer: TimerWorkerProtocol,
         liveActivity: WidgetWorkerProtocol,
         currentCategory: ActivityCategory
        ) {
        self.presenter = presenter
        self.activityRepository = activityRepository
        self.hapticWorker = hapticWorker
        self.coreMotionWorker = coreMotionWorker
        self.foundationWorker = foundationWorker
        self.camera = camera
        self.timer = timer
        self.liveActivity = liveActivity
        self.category = currentCategory
    }
    
    // MARK: - Navigation
    //
    // Por enquanto só pedem ao Presenter para trocar de step.
    // A regra de cada step (sorteio, tempo, humor...) entra nas próximas extensions.
    
    /// Aceitou o desafio sorteado: continua no step `.challenge`,
    /// que passa a mostrar a tela de desafio aceito.
    func acceptActivity() {
        presenter.presentAcceptedActivity()
    }
    
    /// Começou a executar o desafio: também vai para "em andamento".
    func startActivity() {
        startTimer()
        presenter.presentInProgress()
    }
    
    /// Abre os detalhes do desafio.
    func goToActivityDetail() {
        presenter.presentActivityStep()
    }
    
    /// Volta para o sorteio, limpando o desafio anterior.
    func returnToStart() {
        presenter.presentStartAgain()
    }
    
    /// Terminou o desafio: vai para o humor.
    func completeActivity() {
        stopTimer()
        presenter.presentMood()
    }
    
    /// Escolheu o humor: vai para a foto.
    func selectMood() {
        presenter.presentPhoto()
    }
    
    /// Termina o fluxo e volta para a Home.
    func finishActivityFlow() {
        cancelTimer()
        presenter.presentFlowFinished()
    }
}
