//
//  Formatters.swift
//  ChallengeFinal
//
//  Created by Raquel Souza on 16/10/26.
//

import Foundation

// MARK: - Formatadores compartilhados pelos Presenters

enum Formatters {

    /// Tempo da atividade no formato do cronômetro do protótipo: sempre HH:MM:SS.
    ///
    static func duration(_ interval: TimeInterval) -> String {
        let total = max(0, Int(interval.rounded(.down)))

        let hours = total / 3600
        let minutes = (total % 3600) / 60
        let seconds = total % 60

        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
    
    /// Data de criação por extenso, no idioma do aparelho.
    /// date: .long pede a data por extenso. Quem decide a ordem e as palavras (“de”, vírgula, mês antes ou depois do dia) é o sistema, conforme o idioma.
    /// time: .omitted deixa a hora de fora.
    /// .autoupdatingCurrent acompanha o idioma e a região configurados no aparelho.
    static func createdAt(_ date: Date, locale: Locale = .autoupdatingCurrent) -> String {
        date.formatted(
            Date.FormatStyle(date: .long, time: .omitted)
                .locale(locale)
        )
    }
}
