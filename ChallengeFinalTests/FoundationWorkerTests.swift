//
//  FoundationWorkerTests.swift
//  ChallengeFinalTests
//
//  Created by Paulo Henrique Costa Alves on 12/11/26.
//

import Foundation
import Testing
@testable import ChallengeFinal

/// Testa o catálogo de presets e o `FoundationWorker` real.
/// Só cobre o caminho dos presets, que não chama o modelo do aparelho e por isso é determinístico.
@MainActor
@Suite("Tests for FoundationWorker and PresetCatalog")
struct FoundationWorkerTests {

    private let challengeTitleLimit = 42
    private let achievementTitleLimit = 16

    private func finishedChallenge(of worker: FoundationWorker) -> FrictionChallenge? {
        if case .finished(let challenge) = worker.state { return challenge }
        return nil
    }

    private func archivedActivity(from preset: PresetChallenge, category: ActivityCategory) -> Activity {
        // Ao arquivar, a Activity guarda o `subTitle` do desafio na descrição.
        Activity(category: category, result: nil, name: "qualquer título", description: preset.subTitle, archived: true)
    }

    // MARK: - PresetCatalog

    @Test(arguments: ActivityCategory.allCases)
    func everyPresetIsComplete(category: ActivityCategory) {
        let presets = PresetCatalog.challenges(for: category)

        #expect(!presets.isEmpty)
        for preset in presets {
            #expect(!preset.title.isEmpty)
            #expect(preset.title.count <= challengeTitleLimit, "título longo demais: \(preset.title)")
            #expect(!preset.subTitle.isEmpty)
            #expect(!preset.rationale.isEmpty)
            #expect(!preset.achievement.title.isEmpty)
            #expect(preset.achievement.title.count <= achievementTitleLimit, "título da conquista longo demais: \(preset.achievement.title)")
            // O tempo do cronômetro entra no lugar do `{tempo}`, então todo story precisa dele.
            #expect(preset.achievement.description.contains(PresetAchievement.durationPlaceholder), "story sem {tempo}: \(preset.achievement.description)")
        }
    }

    @Test func presetsAreUnique() {
        let all = ActivityCategory.allCases.flatMap { PresetCatalog.challenges(for: $0) }

        // O `subTitle` identifica o preset ao arquivar e ao buscar a conquista; a descrição, ao evitar repetição na sessão.
        #expect(Set(all.map(\.subTitle)).count == all.count)
        #expect(Set(all.map(\.rationale)).count == all.count)
    }

    // MARK: - generate

    @Test(arguments: ActivityCategory.allCases)
    func generateDeliversAPresetOfTheCategory(category: ActivityCategory) async {
        let worker = FoundationWorker()

        await worker.generate(for: category, archived: [])

        guard let challenge = finishedChallenge(of: worker) else {
            Issue.record("o worker deveria terminar com um desafio")
            return
        }
        let preset = PresetCatalog.challenges(for: category).first { $0.rationale == challenge.rationale }
        #expect(preset != nil)
        #expect(challenge.title == preset?.title)
        #expect(challenge.subTitle == preset?.subTitle)
    }

    @Test func generateNeverRepeatsAPresetUntilTheyRunOut() async {
        let category = ActivityCategory.sensorial
        let total = PresetCatalog.challenges(for: category).count
        let worker = FoundationWorker()
        var seen: Set<String> = []

        for _ in 0..<total {
            await worker.generate(for: category, archived: [])
            if let challenge = finishedChallenge(of: worker) { seen.insert(challenge.rationale) }
        }

        #expect(seen.count == total)
    }

    @Test func generateSkipsArchivedPresets() async {
        let category = ActivityCategory.social
        let presets = PresetCatalog.challenges(for: category)
        guard let remaining = presets.randomElement() else {
            Issue.record("o catálogo de conexão está vazio")
            return
        }
        let archived = presets
            .filter { $0 != remaining }
            .map { archivedActivity(from: $0, category: category) }
        let worker = FoundationWorker()

        await worker.generate(for: category, archived: archived)

        #expect(finishedChallenge(of: worker)?.rationale == remaining.rationale)
    }

    // MARK: - generateAchievement

    @Test func presetActivityGetsThePresetAchievement() async throws {
        let category = ActivityCategory.cognitive
        let preset = try #require(PresetCatalog.challenges(for: category).randomElement())
        let activity = Activity(category: category, result: nil, name: "nome do desafio", description: preset.subTitle, archived: false)
        let worker = FoundationWorker()

        let achievement = await worker.generateAchievement(for: activity, elapsed: 4800)

        // Título vem do preset (não do nome da atividade) e o tempo entra no lugar do `{tempo}`.
        #expect(achievement.title == preset.achievement.title)
        #expect(achievement.description == preset.achievement.description.replacingOccurrences(of: "{tempo}", with: "1h 20 min"))
        #expect(!achievement.description.contains("{tempo}"))
    }

    @Test(arguments: [
        (TimeInterval(3600), "1h"),
        (TimeInterval(4800), "1h 20 min"),
        (TimeInterval(1200), "20 min"),
        (TimeInterval(45), "45 s")
    ])
    func presetAchievementCitesTheTimerInTheSpokenFormat(elapsed: TimeInterval, spoken: String) async throws {
        let category = ActivityCategory.physical
        let preset = try #require(PresetCatalog.challenges(for: category).randomElement())
        let activity = Activity(category: category, result: nil, name: "nome do desafio", description: preset.subTitle, archived: false)
        let worker = FoundationWorker()

        let achievement = await worker.generateAchievement(for: activity, elapsed: elapsed)

        #expect(achievement.description.contains(spoken))
    }
}
