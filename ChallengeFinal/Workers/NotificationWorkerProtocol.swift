//
//  PermissionWorkersPlaceholder.swift
//  ChallengeFinal
//

import Foundation

// MARK: - Protocolos (o contrato que o Interactor usa)

protocol NotificationWorkerProtocol: AnyObject {
    func requestPermission(completion: @escaping (Bool) -> Void)
}

protocol LocalizationWorkerProtocol: AnyObject {
    func requestPermission(completion: @escaping (Bool) -> Void)
}

// MARK: - Provisório

// TODO: trocar pelo NotificationWorker e pelo LocalizationWorker de verdade.
/// Não pede permissão ao sistema: responde "permitido" na hora, só para o app buildar.
final class PermissionWorkerPlaceholder: NotificationWorkerProtocol, LocalizationWorkerProtocol {
    func requestPermission(completion: @escaping (Bool) -> Void) {
        completion(true)
    }
}