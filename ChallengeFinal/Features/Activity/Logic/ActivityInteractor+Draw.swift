//
//  ActivityInteractor+Draw.swift
//  ChallengeFinal
//
//  Created by Raquel Souza on 19/10/26.
//

import Foundation
import FoundationModels

// MARK: - Step .draw

/// Ações da tela de sorteio: detectar o chacoalhar, gerar o desafio
/// com o FoundationWorker e arquivar desafios.
extension ActivityInteractor {
    
    // MARK: Detecção do chacoalhar

    /// A tela de sorteio apareceu: começa a ouvir o acelerômetro.
    ///
    /// Liga três coisas:
    /// 1. O acelerômetro (CoreMotion), que avisa a força de cada movimento.
    /// 2. O haptic contínuo, que vibra junto com o chacoalhar.
    /// 3. Um timer que percebe quando a pessoa parou, para encerrar o haptic.
    ///
    /// Quem encerra isso é o `finishDetection()`, quando a tela some.
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
        
        // Como não há um evento de "parou de sacudir", verificamos periodicamente
        // se faz tempo que não chega leitura acima do threshold e paramos o haptic.
        shakeIdleTimer?.invalidate()
        shakeIdleTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            // O closure do Timer é Sendable; o timer foi agendado na main run loop,
            // então podemos assumir o isolamento do MainActor para acessar o worker.
            MainActor.assumeIsolated {
                self?.hapticWorker.stopShakeLoopIfIdle(timeout: 0.25)
            }
        }
    }
    
    // MARK: Preparação e arquivo

    /// "Aquece" o modelo de linguagem para a categoria, assim o sorteio responde mais rápido.
    /// Só faz algo se o Foundation Models estiver disponível no aparelho.
    func prepare(for category: ActivityCategory) {
        if foundationWorker.availability == .available {
            foundationWorker.prewarm(for: category)
        }
    }
    
    /// "Arquivar desafio da lista": salva o desafio como `archived`.
    /// O sorteio usa os arquivados para não repetir esse tipo de desafio.
    func archiveChallenge(title: String, description: String, in category: ActivityCategory) {
        let activity = Activity(category: category, result: nil, name: title, description: description, archived: true)
        do {
            try activityRepository.add(activity)
            prepare(for: category)
        } catch {
            print("Erro ao adicionar elemento: \(error.localizedDescription)")
        }
    }
    
    /// Sorteia outro desafio sem precisar chacoalhar de novo.
    func reroll(for category: ActivityCategory) {
        raffle(for: category)
    }
    
    /// A tela de sorteio saiu: desliga acelerômetro, timer e haptic.
    /// Sem isso o celular continuaria vibrando em outros steps.
    func finishDetection() {
        coreMotionWorker.stopMonitoring()
        shakeIdleTimer?.invalidate()
        shakeIdleTimer = nil
        hapticWorker.stopShakeLoop()
    }
    
    // MARK: Auxiliares privados

    /// Gera o desafio com o Foundation Models, em 3 passos:
    /// 1. Avisa o Presenter que está procurando (a tela troca o texto).
    /// 2. Pede ao worker um desafio, passando os arquivados para ele evitar.
    /// 3. Entrega o resultado: o desafio pronto ou "falhou".
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
