//
//  WatchMotionWorker.swift
//  ChallengeFinalWatch Watch App
//
//  Created by Paulo Henrique Costa Alves on 23/11/26.
//

import Foundation
import CoreMotion

// MARK: - Protocol

/// O que o Interactor enxerga da detecção de movimento: ligar, desligar e ser avisado do chacoalhar.
///
/// O worker só detecta o movimento; quem decide o que fazer com ele é o Interactor.
/// Com o protocolo, nos testes dá para passar um worker falso que "chacoalha" na hora.
@MainActor
protocol WatchMotionWorkerProtocol: AnyObject {
    /// Chamado quando o relógio é chacoalhado com força. Chega na main thread.
    var onShake: (() -> Void)? { get set }

    func startMonitoring()
    func stopMonitoring()
}

// MARK: - Class

/// Lê o acelerômetro e avisa quando o relógio é chacoalhado.
/// Base: o `CoreMotionWorker` do iOS, sem o feedback contínuo de haptic.
///
/// A cada leitura (10 por segundo) compara a aceleração com a anterior; se a variação passa de
/// `shakeThreshold`, é uma sacudida. O `shakeCooldown` faz uma única sacudida, que gera várias
/// leituras acima do limite em sequência, contar como um só aviso.
@MainActor
final class WatchMotionWorker: WatchMotionWorkerProtocol {

    private let motionManager = CMMotionManager()

    /// Leitura anterior. `nil` = ainda não houve leitura, então a primeira não gera aviso
    /// (comparada com zero, a gravidade já pareceria um movimento).
    private var lastAcceleration: CMAcceleration?
    private var lastShakeDate: Date?

    /// Variação mínima (em g, somando os três eixos) para contar como sacudida.
    var shakeThreshold: Double = 2.5

    /// Tempo mínimo entre dois avisos.
    var shakeCooldown: TimeInterval = 1.0

    var onShake: (() -> Void)?

    func startMonitoring() {
        // O simulador não tem acelerômetro: aí nada acontece e só o toque sorteia.
        guard motionManager.isAccelerometerAvailable else { return }

        lastAcceleration = nil
        lastShakeDate = nil
        motionManager.accelerometerUpdateInterval = 0.1
        motionManager.startAccelerometerUpdates(to: .main) { [weak self] data, _ in
            // O handler roda na main queue, então dá para assumir o isolamento do MainActor.
            MainActor.assumeIsolated {
                guard let self, let data else { return }
                self.handle(data.acceleration)
            }
        }
    }

    func stopMonitoring() {
        motionManager.stopAccelerometerUpdates()
        lastAcceleration = nil
    }

    // MARK: - Privado

    private func handle(_ acceleration: CMAcceleration) {
        defer { lastAcceleration = acceleration }
        guard let last = lastAcceleration else { return }

        let delta = abs(acceleration.x - last.x)
            + abs(acceleration.y - last.y)
            + abs(acceleration.z - last.z)
        guard delta > shakeThreshold else { return }

        let now = Date()
        if let lastShakeDate, now.timeIntervalSince(lastShakeDate) < shakeCooldown {
            return
        }
        lastShakeDate = now
        onShake?()
    }
}
