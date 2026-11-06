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
    // Chamado quando o loop contínuo é parado por inatividade (ou seja, a
    // pessoa realmente parou de sacudir) — não dispara em um stop manual.
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
                Task { @MainActor in self?.isEngineRunning = false }
            }
            // Reset do servidor de haptics: players antigos ficam inválidos.
            newEngine.resetHandler = { @Sendable [weak self] in
                Task { @MainActor in
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
        guard continuousPlayer == nil else { return }
        
        let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.8)
        let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.3)
        // Duração longa: o evento fica "aberto" até chamarmos stop() explicitamente.
        let event = CHHapticEvent(eventType: .hapticContinuous, parameters: [intensity, sharpness], relativeTime: 0, duration: 100)
        
        do {
            let pattern = try CHHapticPattern(events: [event], parameters: [])
            continuousPlayer = try engine?.makeAdvancedPlayer(with: pattern)
            try continuousPlayer?.start(atTime: CHHapticTimeImmediate)
        } catch {
            print("Failed to start shake loop: \(error.localizedDescription)")
        }
    }
    
    func updateShakeIntensity(_ magnitude: Double) {
        lastMotionDate = Date()
        guard let continuousPlayer else { return }
        
        let value = Float(min(max(magnitude, 0), 1))
        let intensityParam = CHHapticDynamicParameter(parameterID: .hapticIntensityControl, value: value, relativeTime: 0)
        let sharpnessParam = CHHapticDynamicParameter(parameterID: .hapticSharpnessControl, value: value, relativeTime: 0)
        
        do {
            try continuousPlayer.sendParameters([intensityParam, sharpnessParam], atTime: CHHapticTimeImmediate)
        } catch {
            print("Failed to update shake intensity: \(error.localizedDescription)")
        }
    }
    
    func stopShakeLoopIfIdle(timeout: TimeInterval = 0.25) {
        guard continuousPlayer != nil else { return }
        guard let lastMotionDate, Date().timeIntervalSince(lastMotionDate) > timeout else { return }
        stopShakeLoop()
        onShakeSessionEnded?()
    }
    
    func stopShakeLoop() {
        try? continuousPlayer?.stop(atTime: CHHapticTimeImmediate)
        continuousPlayer = nil
        lastMotionDate = nil
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
    
    //Reúne a lógica que antes ficava dentro do playSelectionTick()
    /// Toca um único evento transitório, garantindo que a engine existe e está ligada.
    private func playTransient(intensity: Float, sharpness: Float) {
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
            
            let event = CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: intensity),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: sharpness)
                ],
                relativeTime: 0
            )
            let pattern = try CHHapticPattern(events: [event], parameters: [])
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
    
    var intensity: Float {
        switch self {
        case .selectionTick: return 0.8
        case .categoryChange: return 0.7
        }
    }
    
    var sharpness: Float {
        switch self {
        case .selectionTick: return 0.8
        case .categoryChange: return 0.4
        }
    }
}
