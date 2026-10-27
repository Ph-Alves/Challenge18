//
//  MotionWorker.swift
//  ChallengeFinal
//
//  Created by Paulo Henrique Costa Alves on 23/10/26.
//

import Foundation
import CoreMotion

protocol CoreMotionWorkerProtocol {
    var shakeThreshold: Double { get set }
    var shakeCooldown: TimeInterval { get set }
    var onMotionUpdate: ((Double) -> Void)? { get set }
    
    func startMonitoring()
    func stopMonitoring()
}

final class CoreMotionWorker: CoreMotionWorkerProtocol {
    private let motionManager = CMMotionManager()
    private var lastAcceleration: CMAcceleration = CMAcceleration(x: 0, y: 0, z: 0)
    private var lastShakeDate: Date?
    
    var shakeThreshold: Double = 2.5
    // Tempo mínimo entre dois disparos, para que uma única sacudida (que gera
    // várias leituras acima do threshold em sequência) conte como um só evento.
    var shakeCooldown: TimeInterval = 1.0
    // Chamado a cada leitura do acelerômetro (10x por segundo), com a magnitude
    // bruta da variação. Usado para alimentar um haptic contínuo em tempo real,
    // diferente do onShake, que só dispara uma vez por sacudida (com cooldown).
    var onMotionUpdate: ((Double) -> Void)?
    
    func startMonitoring() {
        guard motionManager.isAccelerometerAvailable else { return }
        motionManager.accelerometerUpdateInterval = 0.1
        motionManager.startAccelerometerUpdates(to: .main) { [weak self] data, _ in
            guard let self, let data else { return }
            
            let acceleration = data.acceleration
            let delta = abs(acceleration.x - self.lastAcceleration.x)
            + abs(acceleration.y - self.lastAcceleration.y)
            + abs(acceleration.z - self.lastAcceleration.z)
            self.lastAcceleration = acceleration
            
            self.onMotionUpdate?(delta)
            
            guard delta > self.shakeThreshold else { return }
            
            let now = Date()
            if let lastShakeDate, now.timeIntervalSince(lastShakeDate) < self.shakeCooldown {
                return
            }
            self.lastShakeDate = now
        }
    }
    
    func stopMonitoring() {
        motionManager.stopAccelerometerUpdates()
    }
}
