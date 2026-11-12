//
//  FoundationWorker.swift
//  ChallengeFinal
//
//  Created by Paulo Henrique Costa Alves on 23/10/26.
//

import Foundation
import FoundationModels
import Observation

/// Um desafio completo, pronto para ser mostrado na tela.
@Generable
struct FrictionChallenge: Sendable {
    @Guide(
        description:
            "Frase curta e imperativa, em minúsculas, que resume o desafio. No máximo 42 caracteres, contando espaços. Exemplo: faça o seu cárdio sem abrir redes sociais"
    )
    var title: String

    @Guide(
        description:
            "Nome curto do desafio, até 5 palavras. Exemplo: Cardio sem fones"
    )
    var subTitle: String

    @Guide(
        description:
            "Uma ou duas frases dizendo o que fazer e como isso ajuda a desacelerar a mente. Tom acolhedor e direto."
    )
    var rationale: String
}

/// Usado quando o desafio foi completo, para gerar uma conquista
@Generable
struct Achievement: Sendable {
    @Guide(
        description:
            "minúsculas, 2 a 3 palavras e no máximo 16 caracteres, contando espaços, como em mestre offline"
    )
    var title: String

    @Guide(
        description:
            "2ª pessoa e passado, como em você passou 1h se exercitando sem…"
    )
    var description: String
}

extension ActivityCategory {
    /// Descrição da categoria usada nos prompts.
    fileprivate var focus: String {
        switch self {
        case .physical:
            return "movimento (exercícios, caminhadas e rotina física)"
        case .cognitive:
            return "mente (cálculo, memória, planejamento e criatividade)"
        case .sensorial:
            return
                "sentidos (atenção plena, observação, tato e pausas sem telas)"
        case .social:
            return "conexão (conversar, elogiar e se reaproximar de pessoas)"
        }
    }
}

/// Dados da requisição atual, sem depender do modelo do SwiftData.
struct FrictionContext: Sendable {
    var category: ActivityCategory
    /// Nomes das atividades arquivadas.
    var archivedTitles: [String]
    /// Descrições das atividades arquivadas (guardam o `subTitle`), usadas para reconhecer presets já arquivados.
    var archivedDescriptions: [String]
}

/// Limites de caracteres dos títulos exibidos na tela.
private enum TitleLimit {
    static let challenge = 42
    static let achievement = 16
}

private extension String {
    /// Corta em palavras inteiras para caber em `limit` caracteres; se a primeira palavra já passa do limite, corta nela.
    /// O modelo nem sempre respeita o limite do `@Guide`, então este é o último filtro.
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

private enum EngineError: Error {
    case modelUnavailable
    case incompleteResponse
}

/// Base comum a todas as categorias: o norte de fricção mental.
private let frictionBaseInstructions = """
    Você é um coach que cria pequenos desafios de fricção mental: quebras de rotina que desaceleram a mente e tiram a pessoa do piloto automático.

    A ideia central é trocar o caminho mais fácil e automático por um pouco de atenção e presença, sem dar muito trabalho.

    Regras:
    - Responda sempre em português do Brasil, com tom acolhedor e direto.
    - Segurança física vem sempre primeiro: nunca proponha nada que aumente risco de lesão, acidente ou distração perigosa.
    - O desafio deve ser simples, curto e executável sem equipamento extra.
    - Seja específico para a categoria recebida; desafios genéricos não funcionam.
    - Nunca repita nem se aproxime dos desafios que a pessoa já viu.
    """

extension ActivityCategory {
    /// Instruções da sessão: a base de fricção mental mais o que é próprio da categoria.
    fileprivate var instructions: String {
        frictionBaseInstructions + "\n\n" + categoryInstructions
    }

    /// Faixa de temperatura da geração. Movimento e sentidos pedem mais precisão (segurança e ações exatas);
    /// mente e conexão ganham com mais variedade de ideias.
    fileprivate var creativity: Range<Double> {
        switch self {
        case .physical: return 0.3..<0.7
        case .sensorial: return 0.4..<0.8
        case .cognitive: return 0.6..<1.0
        case .social: return 0.5..<0.9
        }
    }

    private var categoryInstructions: String {
        switch self {
        case .physical:
            return """
                Categoria: movimento.
                - Proponha pequenas mudanças na rotina do corpo: escolher o caminho menos cômodo, caminhar ou se exercitar sem música nem telas, mudar o horário ou o jeito de fazer algo.
                - Prefira gestos do dia a dia a treinos longos; nada de esforço extremo.
                - O foco é perceber o corpo e o ambiente, não desempenho.
                """
        case .sensorial:
            return """
                Categoria: sentidos.
                - Proponha prestar atenção em tato, visão, audição, paladar ou olfato, ou fazer pausas sem telas.
                - O desafio é observar ou sentir algo presente, sem produzir nada nem usar o celular.
                - Use objetos e espaços que a pessoa já tem por perto.
                """
        case .cognitive:
            return """
                Categoria: mente.
                - Proponha exercitar cálculo mental, memória, planejamento ou criatividade, fazendo sem o apoio que a pessoa costuma usar (calculadora, aplicativos, mapas).
                - Pode ser conferir o resultado depois, mas só depois de tentar sozinha.
                - O esforço deve ser leve e curioso, nunca uma prova.
                """
        case .social:
            return """
                Categoria: conexão.
                - Proponha pequenos gestos reais com outras pessoas: conversar, elogiar com sinceridade, ligar em vez de usar aplicativo, retomar um contato.
                - Respeite o contexto: só interações apropriadas, sem pressionar ninguém nem expor dados pessoais.
                - O foco é presença e gentileza, não carisma.
                """
        }
    }
}

/// Base comum das conquistas: formato do texto e o norte de fricção mental.
private let achievementBaseInstructions = """
    Você escreve conquistas curtas para celebrar um desafio de fricção mental que a pessoa acabou de completar: uma quebra de rotina que a tirou do piloto automático.

    Regras:
    - Responda sempre em português do Brasil, em minúsculas, com tom acolhedor e sem exagero.
    - O título tem de 2 a 3 palavras, no máximo 16 caracteres contando espaços, e funciona como um apelido para a pessoa. Exemplo: mestre offline
    - A descrição fala com a pessoa na 2ª pessoa e no passado, em uma frase. Exemplo: você passou 1h se exercitando sem entrar em nenhuma rede social
    - A descrição deve citar o tempo recebido exatamente como foi escrito, sem converter nem arredondar.
    - Use só o que foi informado sobre o desafio; não invente fatos.
    """

extension ActivityCategory {
    /// Instruções da conquista: a base mais o que é próprio da categoria.
    fileprivate var achievementInstructions: String {
        achievementBaseInstructions + "\n\n" + achievementCategoryInstructions
    }

    private var achievementCategoryInstructions: String {
        switch self {
        case .physical:
            return """
                Categoria: movimento.
                - O apelido destaca o corpo em movimento sem pressa nem telas. Exemplo: corpo presente
                - Valorize o gesto de escolher o caminho menos automático, não o desempenho.
                """
        case .sensorial:
            return """
                Categoria: sentidos.
                - O apelido destaca a atenção ao que estava ao redor. Exemplo: olhar atento
                - Valorize o ato de perceber e sentir, sem falar em produtividade.
                """
        case .cognitive:
            return """
                Categoria: mente.
                - O apelido destaca a mente ativa, feita sem apoio. Exemplo: cabeça ativa
                - Valorize a curiosidade e o esforço leve, sem tom de prova ou nota.
                """
        case .social:
            return """
                Categoria: conexão.
                - O apelido destaca a presença e a gentileza com outras pessoas. Exemplo: elo vivo
                - Valorize o gesto de se aproximar, sem citar nomes nem expor detalhes de ninguém.
                """
        }
    }
}

enum FoundationWorkerState {
    case idle
    case loading
    // Não vamos usar streaming por enquanto, mas pode ser util pra montar animações.
    case streaming(FrictionChallenge.PartiallyGenerated)
    case finished(FrictionChallenge)
    case failed(String)
}

@MainActor
protocol FoundationWorkerProtocol: AnyObject {
    var state: FoundationWorkerState { get }
    var availability: SystemLanguageModel.Availability { get }

    func prewarm(for category: ActivityCategory)
    func generate(for category: ActivityCategory, archived: [Activity]) async
    /// Conquista de uma atividade concluída: a do preset, ou gerada pelo modelo quando o desafio foi gerado.
    /// Nunca falha: sem o modelo, devolve um texto padrão.
    func generateAchievement(for activity: Activity, elapsed: TimeInterval)
        async -> Achievement
}

/// Entrega um desafio para uma categoria, intercalando desafios 100% gerados pelo modelo
/// com desafios pré-prontos em que o modelo escreve só o título.
@MainActor
@Observable
final class FoundationWorker: FoundationWorkerProtocol {

    private(set) var state: FoundationWorkerState = .idle

    /// Sessão aquecida e a categoria dela, porque cada categoria tem instruções próprias.
    private var challengeSession:
        (category: ActivityCategory, session: LanguageModelSession)?
    private var achievementSession: LanguageModelSession?

    /// Presets e títulos já mostrados nesta sessão, para o "outro desafio" não repetir.
    private var seenPresets: Set<String> = []
    private var seenTitles: [String] = []

    /// Whether the on-device model is ready to use right now.
    var availability: SystemLanguageModel.Availability {
        SystemLanguageModel.default.availability
    }

    /// Carrega o modelo antes do uso, para o primeiro desafio sair mais rápido.
    func prewarm(for category: ActivityCategory) {
        guard availability == .available else { return }
        let activeSession = makeSession(for: category)
        challengeSession = (category, activeSession)
        activeSession.prewarm(
            promptPrefix: Prompt("categoria: \(category.focus)")
        )
    }

    func generate(for category: ActivityCategory, archived: [Activity]) async {
        state = .loading

        let context = FrictionContext(
            category: category,
            archivedTitles: archived.map(\.name),
            archivedDescriptions: archived.map(\.activityDescription)
        )
        // Enquanto houver preset novo na categoria, sorteia um deles (sem chamar o modelo);
        // acabando, o modelo gera o desafio inteiro.
        if let preset = nextPreset(for: context) {
            finish(with: challenge(from: preset), usedPreset: preset)
            return
        }

        do {
            let challenge = try await generatedChallenge(context: context)
            finish(with: challenge, usedPreset: nil)
        } catch {
            // Sem modelo (ou com erro), um preset garante que a pessoa sempre receba um desafio.
            if let fallback = PresetCatalog.challenges(for: category)
                .randomElement()
            {
                finish(with: challenge(from: fallback), usedPreset: fallback)
            } else {
                state = .failed(Self.message(for: error))
            }
        }
    }

    /// Conquista da atividade, citando o tempo do cronômetro. Se o desafio veio de um preset, usa a
    /// conquista escrita nele (o tempo entra no lugar do `{tempo}`); só desafios gerados pelo modelo
    /// ganham uma conquista gerada.
    func generateAchievement(for activity: Activity, elapsed: TimeInterval)
        async -> Achievement
    {
        let name = activity.name
        let details = activity.activityDescription
        let duration = Self.spokenDuration(elapsed)

        // A atividade guarda o `subTitle` do desafio na `activityDescription`, que identifica o preset.
        if let preset = PresetCatalog.challenges(for: activity.category)
            .first(where: { $0.subTitle == details })
        {
            return Achievement(
                title: preset.achievement.title.fitted(to: TitleLimit.achievement),
                description: preset.achievement.description(duration: duration)
            )
        }

        do {
            guard availability == .available else {
                throw EngineError.modelUnavailable
            }

            var options = GenerationOptions()
            options.temperature = Double.random(in: 0.4..<0.6)

            let session = makeAchievementSession(for: activity.category)
            achievementSession = session
            let response = try await session.respond(
                to: achievementPrompt(
                    name: name,
                    details: details,
                    category: activity.category,
                    duration: duration
                ),
                generating: Achievement.self,
                options: options
            )

            let title = response.content.title.trimmingCharacters(
                in: .whitespacesAndNewlines
            )
            let description = response.content.description.trimmingCharacters(
                in: .whitespacesAndNewlines
            )
            // Sem o tempo na descrição, o texto não cumpre o que a conquista promete.
            guard !title.isEmpty, description.contains(duration) else {
                throw EngineError.incompleteResponse
            }
            return Achievement(
                title: title.fitted(to: TitleLimit.achievement),
                description: description
            )
        } catch {
            return Achievement(
                title: name.fitted(to: TitleLimit.achievement),
                description: "você completou \(name) em \(duration)"
            )
        }
    }

    // MARK: - Generation

    /// Desafio 100% gerado: título, subtítulo e descrição.
    private func generatedChallenge(context: FrictionContext) async throws
        -> FrictionChallenge
    {
        guard availability == .available else {
            throw EngineError.modelUnavailable
        }

        var options = GenerationOptions()
        options.temperature = Double.random(in: context.category.creativity)

        let responseStream = takeSession(for: context.category).streamResponse(
            to: fullPrompt(for: context),
            generating: FrictionChallenge.self,
            options: options
        )

        var latest: FrictionChallenge.PartiallyGenerated?
        for try await snapshot in responseStream {
            latest = snapshot.content
            state = .streaming(snapshot.content)
        }

        // O último snapshot é o resultado completo.
        guard let title = latest?.title, let subTitle = latest?.subTitle,
            let rationale = latest?.rationale
        else {
            throw EngineError.incompleteResponse
        }
        return FrictionChallenge(
            title: title.fitted(to: TitleLimit.challenge),
            subTitle: subTitle,
            rationale: rationale
        )
    }

    /// Preset já traz o título (motivador) escrito à mão.
    private func challenge(from preset: PresetChallenge) -> FrictionChallenge {
        FrictionChallenge(
            title: preset.title.fitted(to: TitleLimit.challenge),
            subTitle: preset.subTitle,
            rationale: preset.rationale
        )
    }

    private func finish(
        with challenge: FrictionChallenge,
        usedPreset: PresetChallenge?
    ) {
        seenTitles.append(challenge.title)
        if let usedPreset { seenPresets.insert(usedPreset.rationale) }
        state = .finished(challenge)
    }

    // MARK: - Presets

    /// Sorteia um preset da categoria que não esteja arquivado nem tenha sido mostrado nesta sessão.
    /// Devolve `nil` quando todos já foram usados.
    private func nextPreset(for context: FrictionContext) -> PresetChallenge? {
        // Ao arquivar, a Activity guarda o título no `name` e o `subTitle` do desafio na `activityDescription`.
        // O nome do preset também vira título quando o modelo falha, então olhamos os dois campos.
        let archived = Set(
            context.archivedDescriptions + context.archivedTitles
        )
        return PresetCatalog.challenges(for: context.category)
            .filter {
                !archived.contains($0.subTitle)
                    && !seenPresets.contains($0.rationale)
            }
            .randomElement()
    }

    // MARK: - Prompts

    private func fullPrompt(for context: FrictionContext) -> String {
        var lines = [
            "categoria: \(context.category.focus)",
            "Crie um desafio novo para essa categoria.",
        ]

        let examples = PresetCatalog.challenges(for: context.category)
            .shuffled().prefix(2)
        if !examples.isEmpty {
            lines.append("Exemplos do estilo esperado (não copie):")
            lines += examples.map { "- \($0.subTitle): \($0.rationale)" }
        }

        lines += avoidLines(for: context)
        return lines.joined(separator: "\n")
    }

    private func achievementPrompt(
        name: String,
        details: String,
        category: ActivityCategory,
        duration: String
    ) -> String {
        """
        categoria: \(category.focus)
        desafio: \(name)
        detalhes: \(details)
        tempo: \(duration)
        Escreva a conquista dessa pessoa citando o tempo "\(duration)" na descrição.
        """
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

    /// Lista os desafios já vistos (arquivados e desta sessão), limitada para não estourar o contexto.
    private func avoidLines(for context: FrictionContext) -> [String] {
        let avoided = (context.archivedTitles + seenTitles).suffix(20)
        guard !avoided.isEmpty else { return [] }
        return ["Não repita nem se aproxime destes desafios já vistos:"]
            + avoided.map { "- \($0)" }
    }

    // MARK: - Session setup

    /// Usa a sessão aquecida, se for da mesma categoria. Cada desafio usa uma sessão nova para o histórico não crescer.
    private func takeSession(for category: ActivityCategory)
        -> LanguageModelSession
    {
        defer { challengeSession = nil }
        if let warmed = challengeSession, warmed.category == category {
            return warmed.session
        }
        return makeSession(for: category)
    }

    /// Sessão com as instruções da categoria.
    private func makeSession(for category: ActivityCategory)
        -> LanguageModelSession
    {
        LanguageModelSession(
            model: .default,
            instructions: category.instructions
        )
    }

    /// Sessão da conquista com as instruções da categoria.
    private func makeAchievementSession(for category: ActivityCategory)
        -> LanguageModelSession
    {
        LanguageModelSession(
            model: .default,
            instructions: category.achievementInstructions
        )
    }

    private static func message(for error: Error) -> String {
        if let engineError = error as? EngineError {
            switch engineError {
            case .modelUnavailable:
                return
                    "Não foi possível gerar um desafio agora. Verifique se a Apple Intelligence está ativada em Ajustes."
            case .incompleteResponse:
                return "O desafio veio incompleto. Tente novamente."
            }
        }

        // LanguageModelError e SystemLanguageModel.Error só existem no SDK do Xcode 27 (Swift 6.4).
        // Com SDKs anteriores (ex.: CI com Xcode 26.x) este trecho nem é compilado.
        #if compiler(>=6.4)
            if #available(iOS 27.0, macOS 27.0, visionOS 27.0, *),
                let modelError = error as? LanguageModelError
            {
                switch modelError {
                case .contextSizeExceeded:
                    return "A conversa ficou grande demais. Tente novamente."
                case .guardrailViolation:
                    return
                        "Não foi possível criar esse desafio por motivos de segurança. Tente novamente."
                case .unsupportedLanguageOrLocale:
                    return
                        "O idioma atual não é compatível com o modelo neste aparelho."
                case .rateLimited:
                    return
                        "Muitos pedidos em pouco tempo. Aguarde um instante e tente de novo."
                case .refusal:
                    return
                        "O modelo não conseguiu criar um desafio. Tente novamente."
                default:
                    return "Não foi possível gerar o desafio agora."
                }
            }

            if #available(iOS 27.0, macOS 27.0, visionOS 27.0, *),
                let systemError = error as? SystemLanguageModel.Error
            {
                switch systemError {
                case .assetsUnavailable:
                    return
                        "O modelo ainda está sendo preparado neste aparelho, ou a Apple Intelligence está desativada. Verifique os Ajustes e tente novamente."
                @unknown default:
                    return "Não foi possível gerar o desafio agora."
                }
            }
        #endif

        // iOS 26 (antes de existir o LanguageModelError) lança este tipo.
        if let generationError = error as? LanguageModelSession.GenerationError
        {
            switch generationError {
            case .exceededContextWindowSize:
                return "A conversa ficou grande demais. Tente novamente."
            case .guardrailViolation:
                return
                    "Não foi possível criar esse desafio por motivos de segurança. Tente novamente."
            case .unsupportedLanguageOrLocale:
                return
                    "O idioma atual não é compatível com o modelo neste aparelho."
            case .rateLimited:
                return
                    "Muitos pedidos em pouco tempo. Aguarde um instante e tente de novo."
            case .refusal:
                return
                    "O modelo não conseguiu criar um desafio. Tente novamente."
            case .assetsUnavailable:
                return
                    "O modelo ainda está sendo preparado neste aparelho. Tente novamente em breve."
            case .decodingFailure, .unsupportedGuide:
                return
                    "O desafio veio em um formato inesperado. Tente novamente."
            default:
                return "Não foi possível gerar o desafio agora."
            }
        }

        if error.localizedDescription.localizedCaseInsensitiveContains("asset")
        {
            return
                "O modelo do aparelho não está disponível agora. Verifique se a Apple Intelligence está ativada, se o aparelho não está no Modo de Pouca Energia, e tente de novo."
        }

        return "Não foi possível gerar o desafio agora."
    }
}
