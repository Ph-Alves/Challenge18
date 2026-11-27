//
//  WatchPresetWorker.swift
//  ChallengeFinalWatch Watch App
//
//  Created by Paulo Henrique Costa Alves on 23/11/26.
//

import Foundation

// MARK: - Auxiliares

/// Limites de caracteres dos títulos exibidos na tela (os mesmos do iOS).
private enum TitleLimit {
    static let challenge = 42
    static let achievement = 16
}

private extension String {
    /// Corta em palavras inteiras para caber em `limit` caracteres; se a primeira palavra já passa do limite, corta nela.
    func fitted(to limit: Int) -> String {
        guard count > limit else { return self }
        let hardCut = String(prefix(limit))
        // Se o próximo caractere é um espaço, o corte já caiu no fim de uma palavra.
        let nextIndex = index(startIndex, offsetBy: limit)
        guard self[nextIndex] != " ", let lastSpace = hardCut.lastIndex(of: " ") else {
            return hardCut.trimmingCharacters(in: .whitespaces)
        }
        return String(hardCut[..<lastSpace]).trimmingCharacters(in: .whitespaces)
    }
}

// MARK: - Protocol

/// O que o Interactor enxerga do worker de presets: sortear um desafio e montar a conquista.
///
/// É o equivalente do `FoundationWorker` do iOS, só com os presets (no Watch não há geração
/// pelo modelo). Com o protocolo, nos testes dá para passar um worker falso e controlar o sorteio.
@MainActor
protocol WatchPresetWorkerProtocol: AnyObject {
    /// Sorteia um desafio da categoria, sem repetir os já vistos. `nil` = a categoria não tem presets.
    func draw(for category: WatchCategory) -> WatchChallenge?

    /// Conquista do desafio sorteado, citando o tempo. `nil` = ainda não há desafio sorteado.
    func achievement(elapsed: TimeInterval) -> WatchAchievement?
}

// MARK: - Class

/// Sorteia os desafios pré-prontos e monta a conquista deles.
///
/// Guarda o que já foi mostrado nesta sessão (para o "outro desafio" não repetir) e o preset
/// sorteado agora, que é de onde sai a conquista.
@MainActor
final class WatchPresetWorker: WatchPresetWorkerProtocol {

    /// Preset sorteado agora. É dele que sai a conquista.
    private var currentPreset: PresetChallenge?

    /// Presets já mostrados nesta sessão (pelo `rationale`).
    private var seenPresets: Set<String> = []

    func draw(for category: WatchCategory) -> WatchChallenge? {
        guard let preset = nextPreset(for: category) else { return nil }

        currentPreset = preset
        seenPresets.insert(preset.rationale)
        return WatchChallenge(
            title: preset.title.fitted(to: TitleLimit.challenge),
            subTitle: preset.subTitle,
            rationale: preset.rationale
        )
    }

    func achievement(elapsed: TimeInterval) -> WatchAchievement? {
        guard let preset = currentPreset else { return nil }

        return WatchAchievement(
            title: preset.achievement.title.fitted(to: TitleLimit.achievement),
            description: preset.achievement.description(duration: Self.spokenDuration(elapsed))
        )
    }

    // MARK: - Privado

    /// Sorteia um preset da categoria que ainda não foi mostrado. Se todos já foram, sorteia outro
    /// qualquer (diferente do atual, quando possível), porque no Watch não há modelo para gerar um novo.
    private func nextPreset(for category: WatchCategory) -> PresetChallenge? {
        let all = PresetCatalog.challenges(for: category)

        if let unseen = all.filter({ !seenPresets.contains($0.rationale) }).randomElement() {
            return unseen
        }
        return all.filter { $0 != currentPreset }.randomElement() ?? all.randomElement()
    }

    /// Tempo para ler em voz alta: "1h", "1h 20 min", "20 min" ou "45 s".
    private static func spokenDuration(_ interval: TimeInterval) -> String {
        let total = max(0, Int(interval.rounded()))
        let hours = total / 3600
        let minutes = (total % 3600) / 60

        switch (hours, minutes) {
        case (0, 0): return "\(total) s"
        case (0, _): return "\(minutes) min"
        case (_, 0): return "\(hours)h"
        default: return "\(hours)h \(minutes) min"
        }
    }
}
