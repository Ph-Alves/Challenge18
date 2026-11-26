//
//  WatchConnectivityWorker.swift
//  ChallengeFinalWatch Watch App
//
//  Created by Paulo Henrique Costa Alves on 26/11/26.
//

import Foundation
import WatchConnectivity

// MARK: - Protocol

/// O que o Interactor enxerga da conexão com o iPhone: só mandar uma atividade concluída.
///
/// Com o protocolo, nos testes dá para passar um worker falso que só anota o que seria enviado.
@MainActor
protocol WatchConnectivityWorkerProtocol: AnyObject {
    /// Liga a sessão com o iPhone. Chamar de novo não faz nada.
    func activate()

    /// Enfileira a atividade para o iPhone. Se ele estiver longe ou com o app fechado, a entrega
    /// acontece quando for possível.
    func send(_ payload: WatchActivityPayload)
}

// MARK: - Class

/// Manda as atividades concluídas no Watch para o iPhone, que é quem grava no banco.
///
/// Usa `transferUserInfo`: o sistema guarda a fila e entrega mesmo com o iPhone fora de alcance
/// ou com o app fechado. Ele garante a entrega, mas não a velocidade.
@MainActor
final class WatchConnectivityWorker: NSObject, WatchConnectivityWorkerProtocol {

    /// Enviados antes de a sessão terminar de ativar. Saem assim que ela ficar pronta.
    private var pending: [WatchActivityPayload] = []

    private var session: WCSession? {
        WCSession.isSupported() ? WCSession.default : nil
    }

    func activate() {
        guard let session, session.activationState != .activated else { return }
        session.delegate = self
        session.activate()
    }

    func send(_ payload: WatchActivityPayload) {
        guard let session else {
            print("[WC Watch] WCSession não é suportada: nada foi enviado")
            return
        }

        guard session.activationState == .activated else {
            print("[WC Watch] sessão ainda não ativa (estado \(session.activationState.rawValue)): atividade \(payload.id) ficou no pending")
            pending.append(payload)
            activate()
            return
        }
        transfer(payload, through: session)
    }

    // MARK: - Privado

    private func transfer(_ payload: WatchActivityPayload, through session: WCSession) {
        do {
            let userInfoTransfer = session.transferUserInfo(try payload.asUserInfo())
            print("[WC Watch] transferUserInfo chamado para \(payload.id) | companionInstalled=\(session.isCompanionAppInstalled) reachable=\(session.isReachable) fila=\(session.outstandingUserInfoTransfers.count) transferindo=\(userInfoTransfer.isTransferring)")
        } catch {
            print("Erro ao montar a atividade para o iPhone: \(error.localizedDescription)")
        }
    }

    private func flushPending() {
        guard let session, session.activationState == .activated else { return }
        let queued = pending
        pending.removeAll()
        queued.forEach { transfer($0, through: session) }
    }
}

// MARK: - WCSessionDelegate

extension WatchConnectivityWorker: WCSessionDelegate {

    /// O sistema chama fora da main thread: volta para ela antes de mexer na fila.
    nonisolated func session(
        _ session: WCSession,
        activationDidCompleteWith activationState: WCSessionActivationState,
        error: Error?
    ) {
        if let error {
            print("Erro ao ativar a sessão com o iPhone: \(error.localizedDescription)")
            return
        }
        print("[WC Watch] ativação concluída: estado=\(activationState.rawValue) companionInstalled=\(session.isCompanionAppInstalled)")
        guard activationState == .activated else { return }
        Task { @MainActor in self.flushPending() }
    }
}
