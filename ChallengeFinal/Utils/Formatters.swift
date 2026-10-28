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
}
