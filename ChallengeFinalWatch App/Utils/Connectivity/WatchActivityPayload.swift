//
//  WatchActivityPayload.swift
//  ChallengeFinalWatch Watch App
//
//  Created by Paulo Henrique Costa Alves on 26/11/26.
//

import Foundation

/// Atividade concluída no Watch, no formato que viaja para o iPhone.
///
/// Este arquivo está nos DOIS targets (Watch e iOS): é a única definição do formato,
/// então os dois lados sempre concordam. Por isso não pode citar `WatchCategory` nem
/// `ActivityCategory`: a categoria viaja como o `rawValue` dos cases, que têm o mesmo nome.
///
/// É `nonisolated` porque os dois targets usam MainActor como padrão e o `WCSession`
/// entrega os dados fora da main thread.
nonisolated struct WatchActivityPayload: Codable, Sendable, Equatable {
    /// Identifica a atividade. Vira o `activityID` no iPhone, que o usa para descartar reentregas.
    let id: UUID
    /// `rawValue` da categoria (`physical`, `cognitive`, `sensorial` ou `social`).
    let category: String
    /// Frase do desafio. Vira `Activity.name`.
    let title: String
    /// Nome curto do desafio. Vira `Activity.activityDescription`.
    let subTitle: String
    /// Tempo do cronômetro, em segundos.
    let time: TimeInterval
    let completedAt: Date
    let achievementTitle: String
    let achievementDescription: String

    // MARK: - Transporte

    /// Chave do dicionário enviado pelo `WCSession`, que só aceita tipos de property list.
    static let userInfoKey = "watchActivityPayload"

    /// Embrulha o payload (como JSON) no dicionário aceito pelo `transferUserInfo`.
    func asUserInfo() throws -> [String: Any] {
        [Self.userInfoKey: try JSONEncoder().encode(self)]
    }

    /// Desfaz o `asUserInfo()`. `nil` = o dicionário não é um payload deste app.
    init?(userInfo: [String: Any]) {
        guard let data = userInfo[Self.userInfoKey] as? Data,
              let payload = try? JSONDecoder().decode(Self.self, from: data) else { return nil }
        self = payload
    }

    init(
        id: UUID = UUID(),
        category: String,
        title: String,
        subTitle: String,
        time: TimeInterval,
        completedAt: Date = Date(),
        achievementTitle: String,
        achievementDescription: String
    ) {
        self.id = id
        self.category = category
        self.title = title
        self.subTitle = subTitle
        self.time = time
        self.completedAt = completedAt
        self.achievementTitle = achievementTitle
        self.achievementDescription = achievementDescription
    }
}
