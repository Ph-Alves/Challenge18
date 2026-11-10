//
//  HapticsWorker.swift
//  ChallengeFinal
//
//  Created by Paulo Henrique Costa Alves on 23/10/26.
//

import Foundation
import CoreHaptics

protocol HapticsWorkerProtocol {
    var onShakeSessionEnded: (() -> Void)? { get set }
    
    func prepareHaptics()
    func startShakeLoop()
    func updateShakeIntensity(_ magnitude: Double)
    func stopShakeLoopIfIdle(timeout: TimeInterval)
    func stopShakeLoop()
    func playSelectionTick()
    func playCategoryChange()
}

final class HapticsWorker: HapticsWorkerProtocol {
    // MARK: - Variables
    private var engine: CHHapticEngine?
    private var continuousPlayer: CHHapticAdvancedPatternPlayer?
    private var lastMotionDate: Date?
    // Sessão de chacoalhar em andamento e quantos "passos" da contagem já passaram.
    private var isShaking = false
    private var shakeTickCount = 0
    private var lastShakeTickDate: Date?
    // Depois do zumbido final, ignora o chacoalhar até a pessoa parar de verdade.
    // Sem isso, continuar sacudindo abriria outra sessão enquanto o sorteio roda.
    private var isWaitingForRest = false
    /// Tempo de cada passo da contagem. A vibração contínua não é cortada em passos:
    /// a contagem só decide quando chega a hora do zumbido final.
    private static let shakeTickInterval: TimeInterval = 0.2
    /// Ao chegar neste passo, toca o zumbido final, para a vibração e sorteia.
    private static let shakeFinishTick = 10
    // Chamado quando a sessão termina: ao chegar no passo final, que é o sinal
    // para sortear. Não dispara se a pessoa parar antes nem em um stop manual.
    var onShakeSessionEnded: (() -> Void)?
    
    private var isEngineRunning = false
    
    // MARK: - Init
    init(engine: CHHapticEngine? = nil) {
        self.engine = engine
    }
    
    // MARK: - Functions
    func prepareHaptics() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        do {
            let newEngine = try CHHapticEngine()
            // Parou (background, interrupção de áudio...): marcamos para religar no próximo toque.
            // Os handlers chegam numa fila interna da CoreHaptics: voltamos para a main.
            newEngine.stoppedHandler = { @Sendable [weak self] _ in
                Task { @MainActor [weak self] in self?.isEngineRunning = false }
            }
            // Reset do servidor de haptics: players antigos ficam inválidos.
            newEngine.resetHandler = { @Sendable [weak self] in
                Task { @MainActor [weak self] in
                    self?.isEngineRunning = false
                    self?.continuousPlayer = nil
                }
            }
            engine = newEngine
            try newEngine.start()
            isEngineRunning = true
        } catch {
            print("There was an error creating the engine: \(error.localizedDescription)")
        }
    }
    
    // Mantém um CHHapticAdvancedPatternPlayer "aberto" enquanto o celular
    // estiver sendo sacudido, modulando intensidade/sharpness em tempo real
    // a cada leitura do acelerômetro via sendParameters.
    func startShakeLoop() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        guard continuousPlayer == nil, !isWaitingForRest else { return }

        let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.8)
        let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.3)
        // Duração longa: o evento fica "aberto" até chamarmos stop() explicitamente.
        let event = CHHapticEvent(eventType: .hapticContinuous, parameters: [intensity, sharpness], relativeTime: 0, duration: 100)

        do {
            let pattern = try CHHapticPattern(events: [event], parameters: [])
            continuousPlayer = try engine?.makeAdvancedPlayer(with: pattern)
            try continuousPlayer?.start(atTime: CHHapticTimeImmediate)
            isShaking = true
            shakeTickCount = 0
            lastShakeTickDate = Date()
        } catch {
            print("Failed to start shake loop: \(error.localizedDescription)")
        }
    }

    func updateShakeIntensity(_ magnitude: Double) {
        let now = Date()
        lastMotionDate = now
        guard let continuousPlayer else { return }

        let value = Float(min(max(magnitude, 0), 1))
        let intensityParam = CHHapticDynamicParameter(parameterID: .hapticIntensityControl, value: value, relativeTime: 0)
        let sharpnessParam = CHHapticDynamicParameter(parameterID: .hapticSharpnessControl, value: value, relativeTime: 0)

        do {
            try continuousPlayer.sendParameters([intensityParam, sharpnessParam], atTime: CHHapticTimeImmediate)
        } catch {
            print("Failed to update shake intensity: \(error.localizedDescription)")
        }

        // Conta o tempo de chacoalhar em passos; no último, é hora do zumbido final.
        if let lastShakeTickDate, now.timeIntervalSince(lastShakeTickDate) >= Self.shakeTickInterval {
            self.lastShakeTickDate = now
            shakeTickCount += 1
            if shakeTickCount >= Self.shakeFinishTick {
                finishShakeSession()
            }
        }
    }

    // Chamado pelo timer do Interactor. Se a pessoa parou de sacudir antes do passo
    // final, a sessão termina do mesmo jeito: zumbido final e sorteio. Se o zumbido
    // já tocou, só libera um novo chacoalhar assim que ela parar de se mexer.
    func stopShakeLoopIfIdle(timeout: TimeInterval = 0.25) {
        guard isShaking || isWaitingForRest else { return }
        guard let lastMotionDate, Date().timeIntervalSince(lastMotionDate) > timeout else { return }
        if isShaking {
            // Já está parada: não precisa esperar por descanso.
            finishShakeSession(waitForRest: false)
        } else {
            resetShakeSession()
        }
    }

    // Stop manual (sair da tela): encerra tudo sem vibrar e sem sortear.
    func stopShakeLoop() {
        resetShakeSession()
    }
    
    // Tique curto e seco, tipo "catraca", para quando a roleta de humor
    // passa de uma fatia para outra.
    func playSelectionTick() {
        playTransient(intensity: HapticFeel.selectionTick.intensity,
                      sharpness: HapticFeel.selectionTick.sharpness)
    }
    
    // Toque um pouco mais "redondo" e encorpado que o tique da roleta, para
    // marcar a troca de grupo (categoria) no swipe horizontal da Home.
    // Valores fixos = mesma sensação em toda troca, nas duas direções.
    func playCategoryChange() {
        playTransient(intensity: HapticFeel.categoryChange.intensity, sharpness: HapticFeel.categoryChange.sharpness)
    }
    
    // MARK: - Private Functions

    // Fim da sessão (chegou no passo final ou a pessoa parou de sacudir): para a
    // vibração contínua, toca o zumbido forte e avisa para sortear.
    // `waitForRest`: ignora o chacoalhar até a pessoa parar, se ela ainda está sacudindo.
    private func finishShakeSession(waitForRest: Bool = true) {
        endShakeSession()
        isWaitingForRest = waitForRest
        playShakeFinish()
        onShakeSessionEnded?()
    }

    private func endShakeSession() {
        try? continuousPlayer?.stop(atTime: CHHapticTimeImmediate)
        continuousPlayer = nil
        isShaking = false
        shakeTickCount = 0
        lastShakeTickDate = nil
    }

    private func resetShakeSession() {
        try? continuousPlayer?.stop(atTime: CHHapticTimeImmediate)
        continuousPlayer = nil
        isShaking = false
        isWaitingForRest = false
        shakeTickCount = 0
        lastShakeTickDate = nil
        lastMotionDate = nil
    }

    // Zumbido contínuo curto e forte quando chega no toque final, para avisar
    // que o sorteio vai acontecer.
    private func playShakeFinish() {
        playEvents([
            CHHapticEvent(
                eventType: .hapticContinuous,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: HapticFeel.shakeFinish.intensity),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: HapticFeel.shakeFinish.sharpness)
                ],
                relativeTime: 0,
                duration: 0.4
            )
        ])
    }

    private func transientEvent(intensity: Float, sharpness: Float) -> CHHapticEvent {
        CHHapticEvent(
            eventType: .hapticTransient,
            parameters: [
                CHHapticEventParameter(parameterID: .hapticIntensity, value: intensity),
                CHHapticEventParameter(parameterID: .hapticSharpness, value: sharpness)
            ],
            relativeTime: 0
        )
    }

    /// Toca um único evento transitório.
    private func playTransient(intensity: Float, sharpness: Float) {
        playEvents([transientEvent(intensity: intensity, sharpness: sharpness)])
    }

    /// Toca os eventos, garantindo que a engine existe e está ligada.
    private func playEvents(_ events: [CHHapticEvent]) {
        // A engine pode ainda não existir (ex.: é a primeira tela a usar haptics).
        // Prepara na primeira vez em vez de exigir uma chamada antes.
        if engine == nil { prepareHaptics() }
        // Sem engine = aparelho sem suporte a haptics.
        guard let engine else { return }

        do {
            if !isEngineRunning {
                try engine.start()
                isEngineRunning = true
            }

            let pattern = try CHHapticPattern(events: events, parameters: [])
            let player = try engine.makePlayer(with: pattern)
            try player.start(atTime: CHHapticTimeImmediate)
        } catch {
            print("Failed to play transient haptic: \(error.localizedDescription)")
        }
    }
}

// MARK: - Intensidades
/// Intensidade/sharpness de cada feedback em um só lugar, para ajustar e validar
/// a sensação sem caçar números mágicos pelo código.
enum HapticFeel {
    case selectionTick
    case categoryChange
    /// Toques normais do chacoalhar no sorteio.
    case shakeTick
    /// Zumbido contínuo curto e forte no toque final do chacoalhar.
    case shakeFinish

    var intensity: Float {
        switch self {
        case .selectionTick: return 0.8
        case .categoryChange: return 0.7
        case .shakeTick: return 0.9
        case .shakeFinish: return 1.0
        }
    }

    var sharpness: Float {
        switch self {
        case .selectionTick: return 0.8
        case .categoryChange: return 0.4
        case .shakeTick: return 0.4
        case .shakeFinish: return 0.5
        }
    }
}
