//
//  ChallengesInteractor.swift
//  ChallengeFinal
//
//  Created by Raquel Souza on 19/10/26.
//

import Foundation
import FoundationModels


protocol ActivityInteractorProtocol: AnyObject {
    func detectMotion(for category: ActivityCategory)
    func archiveChallenge(title: String, description: String, in category: ActivityCategory)
    func reroll(for category: ActivityCategory)
    func acceptChallenge()
    func startChallenge()
    func goToActivityDetail()
    func returnToStart()
    func finishDetection()
    func finishActivity()
    func prepare(for category: ActivityCategory)
}


@MainActor
final class ActivityInteractor: ActivityInteractorProtocol {
    
    private let presenter: ActivityPresenterProtocol
    private let activityRepository: GenericRepository<Activity>
    private var hapticWorker: HapticsWorkerProtocol
    private var coreMotionWorker: CoreMotionWorkerProtocol
    private var foundationWorker: FoundationWorkerProtocol
    
    private var shakeWasStrongEnough = false
    private var shakeIdleTimer: Timer?
    private let motionFeedbackThreshold: Double = 0.3
    private var isRaffling: Bool = false
    
    init(presenter: ActivityPresenter, activityRepository: GenericRepository<Activity>, hapticWorker: HapticsWorkerProtocol, coreMotionWorker: CoreMotionWorkerProtocol, foundationWorker: FoundationWorkerProtocol) {
        self.presenter = presenter
        self.activityRepository = activityRepository
        self.hapticWorker = hapticWorker
        self.coreMotionWorker = coreMotionWorker
        self.foundationWorker = foundationWorker
    }
    
    func detectMotion(for category: ActivityCategory) {
        self.hapticWorker.prepareHaptics()

        // O sorteio só acontece quando o haptic contínuo para por inatividade
        // (pessoa parou de sacudir) e, durante o movimento, a intensidade
        // chegou a cruzar o shakeThreshold — evita sortear com tremores leves.
        self.hapticWorker.onShakeSessionEnded = {
            guard self.shakeWasStrongEnough else { return }
            self.shakeWasStrongEnough = false
            self.raffle(for: category)
        }
        // Haptic contínuo: toca enquanto a variação do acelerômetro estiver
        // acima do threshold, com intensidade proporcional à força do movimento.
        self.coreMotionWorker.onMotionUpdate = { delta in
            guard delta > self.motionFeedbackThreshold else { return }
            self.hapticWorker.startShakeLoop()
            let normalized = min(delta / self.coreMotionWorker.shakeThreshold, 1.0)
            self.hapticWorker.updateShakeIntensity(normalized)
            if delta > self.coreMotionWorker.shakeThreshold {
                self.shakeWasStrongEnough = true
            }
        }
        
        self.coreMotionWorker.startMonitoring()
        
        Task { [weak self] in
            // Como não há um evento de "parou de sacudir", verificamos periodicamente
            // se faz tempo que não chega leitura acima do threshold e paramos o haptic.
            self?.shakeIdleTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
                // O closure do Timer é Sendable; o timer foi agendado na main run loop,
                // então podemos assumir o isolamento do MainActor para acessar o worker.
                MainActor.assumeIsolated {
                    self?.hapticWorker.stopShakeLoopIfIdle(timeout: 0.25)
                }
            }
        }
    }
    
    func prepare(for category: ActivityCategory) {
        if foundationWorker.availability == .available {
            foundationWorker.prewarm(for: category)
        }
    }
    
    func archiveChallenge(title: String, description: String, in category: ActivityCategory) {
        let activity = Activity(category: category, result: nil, name: title, description: description, archived: true)
        do {
            try activityRepository.add(activity)
            prepare(for: category)
        } catch {
            print("Erro ao adicionar elemento: \(error.localizedDescription)")
        }
    }
    
    func reroll(for category: ActivityCategory) {
        raffle(for: category)
    }
    
    func acceptChallenge() {
        presenter.presentAcceptedActivity()
    }
    
    func startChallenge() {
        presenter.presentStartedChallenge()
    }
    
    func goToActivityDetail() {
        presenter.presentActivityDetail()
    }
    
    func returnToStart() {
        presenter.presentStartAgain()
    }
    
    func finishDetection() {
        coreMotionWorker.stopMonitoring()
        shakeIdleTimer?.invalidate()
        shakeIdleTimer = nil
        hapticWorker.stopShakeLoop()
    }
    
    func finishActivity() {
        presenter.presentActivityFinished()
    }
    
    private func raffle(for category: ActivityCategory) {
        Task {
            isRaffling = true
            presenter.presentSearching()
            do {
                let archived: [Activity] = try activityRepository.getAll().filter(\.archived)
                await foundationWorker.generate(for: category, archived: archived)
            } catch {
                print("Erro em buscar atividades: \(error.localizedDescription)")
            }
            
            switch foundationWorker.state {
            case .finished(let challenge):
                presenter.presentChallenge(challenge)
            case .failed(let message):
                print("Erro: \(message)")
                presenter.presentSearchFailed()
            default:
                presenter.presentSearchFailed()
            }
            isRaffling = false
        }
    }
}
