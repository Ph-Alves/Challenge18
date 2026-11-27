//
//  PhoneConnectivityWorker.swift
//  ChallengeFinal
//
//  Created by Paulo Henrique Costa Alves on 26/11/26.
//

import Foundation
import SwiftData
import WatchConnectivity

// MARK: - Importer

/// Transforma uma atividade concluída no Watch em `Activity` + `ActivityResult` no banco do iPhone.
///
/// Fica separado do `PhoneConnectivityWorker` para poder ser testado sem `WCSession`.
@MainActor
struct WatchActivityImporter {

    enum ImportError: Error {
        /// A categoria que veio do Watch não existe no iOS.
        case unknownCategory(String)
    }

    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    /// Grava a atividade. Se ela já foi importada (o `transferUserInfo` pode reentregar), não faz nada.
    func importActivity(_ payload: WatchActivityPayload) throws {
        guard let category = ActivityCategory(rawValue: payload.category) else {
            throw ImportError.unknownCategory(payload.category)
        }
        guard try !alreadyImported(payload.id) else { return }

        // Mesmo formato do `ActivityInteractor.completeActivity`. Sem humor nem foto: o Watch não coleta.
        let result = ActivityResult(
            achievementTitle: payload.achievementTitle,
            achievementDescription: payload.achievementDescription,
            time: payload.time
        )
        let activity = Activity(
            category: category,
            result: result,
            createdAt: payload.completedAt,
            name: payload.title,
            description: payload.subTitle,
            archived: false
        )
        // O id do Watch vira o `activityID`: é ele que identifica uma reentrega.
        activity.activityID = payload.id

        try GenericRepository<Activity>(context: context).add(activity)
    }

    private func alreadyImported(_ id: UUID) throws -> Bool {
        let descriptor = FetchDescriptor<Activity>(predicate: #Predicate { $0.activityID == id })
        return try context.fetchCount(descriptor) > 0
    }
}

// MARK: - Protocol

/// O que o resto do app enxerga da conexão com o Apple Watch: ligar a sessão e saber quando
/// uma atividade foi gravada.
///
/// Com o protocolo, nos testes dá para passar um worker falso que dispara o `onImport` na hora.
@MainActor
protocol PhoneConnectivityWorkerProtocol: AnyObject {
    /// Chamado depois de cada atividade gravada, para as telas recarregarem.
    var onImport: (() -> Void)? { get set }

    /// Liga a sessão com o Watch. É ao ativar que o sistema entrega o que ficou na fila.
    func activate()
}

// MARK: - Worker

/// Recebe do Apple Watch as atividades concluídas e manda gravar.
///
/// O `WCSession` guarda o que o Watch enviou enquanto o app estava fechado e entrega assim que a
/// sessão é ativada, então basta ativar logo na abertura do app (no `init` do `MyApp`).
@MainActor
final class PhoneConnectivityWorker: NSObject, PhoneConnectivityWorkerProtocol {

    private let importer: WatchActivityImporter

    var onImport: (() -> Void)?

    init(importer: WatchActivityImporter) {
        self.importer = importer
        super.init()
    }

    func activate() {
        guard WCSession.isSupported() else { return }
        let session = WCSession.default
        session.delegate = self
        session.activate()
    }

    private func handle(_ payload: WatchActivityPayload) {
        do {
            try importer.importActivity(payload)
            onImport?()
        } catch {
            print("Erro ao importar a atividade do Watch: \(error)")
        }
    }
}

// MARK: - WCSessionDelegate

extension PhoneConnectivityWorker: WCSessionDelegate {

    nonisolated func session(
        _ session: WCSession,
        activationDidCompleteWith activationState: WCSessionActivationState,
        error: Error?
    ) {
        if let error {
            print("Erro ao ativar a sessão com o Watch: \(error.localizedDescription)")
        }
    }

    /// Exigidos no iOS: com vários Watches pareados a sessão é desativada na troca e precisa reativar.
    nonisolated func sessionDidBecomeInactive(_ session: WCSession) {}

    nonisolated func sessionDidDeactivate(_ session: WCSession) {
        session.activate()
    }

    /// O sistema chama fora da main thread: decodifica aqui e grava na main.
    nonisolated func session(_ session: WCSession, didReceiveUserInfo userInfo: [String: Any]) {
        guard let payload = WatchActivityPayload(userInfo: userInfo) else { return }
        Task { @MainActor in self.handle(payload) }
    }
}
