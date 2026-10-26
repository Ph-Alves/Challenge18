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
    @Guide(description: "Frase curta e imperativa, em minúsculas, que resume o desafio e cabe dentro de um círculo. Até 8 palavras. Exemplo: faça o seu cárdio sem abrir redes sociais")
    var title: String

    @Guide(description: "Nome curto do desafio, até 5 palavras. Exemplo: Cardio sem fones")
    var subTitle: String

    @Guide(description: "Uma ou duas frases dizendo o que fazer e como isso ajuda a desacelerar a mente. Tom acolhedor e direto.")
    var rationale: String
}

/// Usado quando o desafio já existe (preset) e o modelo só precisa escrever o título.
@Generable
struct ChallengeTitle: Sendable {
    @Guide(description: "Frase curta e imperativa, em minúsculas, que resume o desafio e cabe dentro de um círculo. Até 8 palavras. Exemplo: faça o seu cárdio sem abrir redes sociais")
    var title: String
}

/// Desafio pré-pronto: já tem `subTitle` e `rationale`, falta o título.
struct PresetChallenge: Hashable, Sendable {
    let subTitle: String
    let rationale: String

    /// Lê uma string no formato "Nome: descrição", separando no primeiro ": ".
    init?(_ raw: String) {
        guard let separator = raw.range(of: ": ") else { return nil }
        let name = raw[..<separator.lowerBound].trimmingCharacters(in: .whitespaces)
        let description = raw[separator.upperBound...].trimmingCharacters(in: .whitespaces)
        guard !name.isEmpty, !description.isEmpty else { return nil }
        self.subTitle = name
        self.rationale = description
    }
}

/// Desafios pré-prontos de cada categoria.
private enum PresetCatalog {
    static func challenges(for category: ActivityCategory) -> [PresetChallenge] {
        switch category {
        case .physical: return movement
        case .sensorial: return senses
        case .cognitive: return mind
        case .social: return connection
        }
    }

    private static let movement: [PresetChallenge] = [
        "Escolha as escadas: Na próxima oportunidade, use as escadas em vez do elevador, se for seguro e viável.",
        "Desça uma parada antes: No próximo trajeto de transporte público, desça uma parada antes da habitual e caminhe o restante, se o percurso for seguro.",
        "Cardio sem fones: Faça 20 minutos de cardio sem música ou podcast. Aproveite para perceber o ritmo do corpo e os sons ao redor.",
        "Dez agachamentos: Faça 10 agachamentos na próxima vez que for ao banheiro",
        "Horas quebradas: Na próxima vez que for treinar, experimente começar em um horário menos convencional, como 18h37, em vez de 18h45"
    ].compactMap { PresetChallenge($0) }

    private static let senses: [PresetChallenge] = [
        "Cinco minutos de nada: Reserve cinco minutos para não fazer absolutamente nada.",
        "Descubra sua própria mão: Observe sua mão e identifique mentalmente o máximo de características que conseguir: linhas, marcas, formatos, texturas e detalhes.",
        "Viste sua memória: Olhe para as roupas que está usando hoje e tente se lembrar onde comprou cada peça",
        "Mude de lugar: Escolha um canto da sua casa onde você nunca costuma se sentar e passe alguns minutos ali.",
        "Uma bebida, presença total: Tome uma bebida quente sem nenhum dispositivo por perto.",
        "Três texturas ao seu redor: Escolha três objetos próximos e toque em cada um. Observe como as texturas são diferentes entre si.",
        "Conte até 137: Conte mentalmente de 1 até 137, sem acelerar para terminar logo.",
        "Conte ao contrário: Conte mentalmente de 50 até 0, prestando atenção em cada número"
    ].compactMap { PresetChallenge($0) }

    private static let mind: [PresetChallenge] = [
        "Um tsuru feito por você: Aprenda a fazer um origami de tsuru seguindo instruções passo a passo.",
        "Bata claras à mão: Na próxima receita adequada, bata as claras em neve manualmente com um batedor, sem usar uma batedeira elétrica.",
        "Organize uma gaveta do guarda-roupa: Escolha uma gaveta do guarda-roupa e reorganize seu conteúdo, decidindo como agrupar e acomodar as peças.",
        "Organize uma gaveta da cozinha: Escolha uma gaveta da cozinha e encontre uma maneira mais prática de organizar seus utensílios.",
        "Quanto é 37 × 7?: Resolva mentalmente 37 × 7 antes de conferir o resultado em uma calculadora.",
        "Quanto é 91 × 3?: Tente calcular 91 × 3 de cabeça. Só use a calculadora depois de chegar à sua resposta.",
        "Planeje no papel: Escreva em uma folha de papel os compromissos que você tem amanhã, sem consultar primeiro o aplicativo de calendário. Depois, confira se esqueceu algo.",
        "Encontre o caminho de memória: Escolha um destino conhecido e tente planejar como chegar lá sem abrir o aplicativo de mapas. Confira a rota antes de sair e priorize a segurança.",
        "O que ficou na memória?: Depois de ler um parágrafo, feche o livro e escreva três informações de que se lembra. Em seguida, confira o texto.",
        "Um sapo de papel: Faça um origami de sapo",
        "Três objetos, uma história: Escolha três objetos que estão sobre sua mesa e invente uma história curta que conecte os três.",
        "Desligue o relógio do treino: Durante seu próximo treino, evite conferir o relógio a todo momento. Concentre-se nas sensações do corpo e siga um ritmo seguro"
    ].compactMap { PresetChallenge($0) }

    private static let connection: [PresetChallenge] = [
        "Peça pelo telefone: Na próxima vez que for pedir comida, ligue diretamente para o estabelecimento em vez de usar um aplicativo, se essa opção estiver disponível.",
        "Descubra um nome: Em uma interação apropriada, pergunte o nome de alguém com quem você ainda não teve a oportunidade de conversar.",
        "Repare em um detalhe: Hoje, faça um elogio sincero a um acessório de alguém, como um brinco, uma bolsa ou um relógio.",
        "Marque algo fora da rotina: Convide um colega para sair em uma quinta-feira e façam algo juntos, mesmo que seja apenas tomar um café depois do trabalho.",
        "Retome uma amizade antiga: Entre em contato com um colega do ensino fundamental com quem você perdeu contato. Mande uma mensagem genuína para saber como ele está."
    ].compactMap { PresetChallenge($0) }
}

private extension ActivityCategory {
    /// Descrição da categoria usada nos prompts.
    var focus: String {
        switch self {
        case .physical: return "movimento (exercícios, caminhadas e rotina física)"
        case .cognitive: return "mente (cálculo, memória, planejamento e criatividade)"
        case .sensorial: return "sentidos (atenção plena, observação, tato e pausas sem telas)"
        case .social: return "conexão (conversar, elogiar e se reaproximar de pessoas)"
        }
    }
}

/// Dados da requisição atual, sem depender do modelo do SwiftData.
struct FrictionContext: Sendable {
    var category: ActivityCategory
    /// Nomes das atividades arquivadas.
    var archivedTitles: [String]
    /// Descrições das atividades arquivadas, usadas para reconhecer presets já arquivados.
    var archivedDescriptions: [String]
}

private enum EngineError: Error {
    case modelUnavailable
    case incompleteResponse
}

private let frictionInstructions = """
Você é um coach que cria pequenos desafios para desacelerar a mente e sair do piloto automático.

Regras:
- Responda sempre em português do Brasil, com tom acolhedor e direto.
- Segurança física vem sempre primeiro: nunca proponha nada que aumente risco de lesão, acidente ou distração perigosa.
- O desafio deve ser simples, curto e executável sem equipamento extra.
- Seja específico para a categoria recebida; desafios genéricos não funcionam.
- Nunca repita nem se aproxime dos desafios que a pessoa já viu.
"""

/// Entrega um desafio para uma categoria, intercalando desafios 100% gerados pelo modelo
/// com desafios pré-prontos em que o modelo escreve só o título.
@MainActor
@Observable
final class FrictionEngine {
    enum State {
        case idle
        case loading
        case streaming(FrictionChallenge.PartiallyGenerated)
        case finished(FrictionChallenge)
        case failed(String)
    }

    private(set) var state: State = .idle

    private var session: LanguageModelSession?

    /// Alterna entre desafio gerado (false) e preset (true). O primeiro é gerado.
    private var usesPresetNext = false
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
        let activeSession = makeSession()
        session = activeSession
        activeSession.prewarm(promptPrefix: Prompt("categoria: \(category.focus)"))
    }

    func generate(for category: ActivityCategory, archived: [Activity]) async {
        state = .loading

        let context = FrictionContext(
            category: category,
            archivedTitles: archived.map(\.name),
            archivedDescriptions: archived.map(\.activityDescription)
        )
        let preset = nextPreset(for: context)
        let wantsPreset = usesPresetNext
        usesPresetNext.toggle()

        do {
            if wantsPreset, let preset {
                let challenge = try await titledChallenge(from: preset, context: context)
                finish(with: challenge, usedPreset: preset)
            } else {
                let challenge = try await generatedChallenge(context: context)
                finish(with: challenge, usedPreset: nil)
            }
        } catch {
            // Sem modelo (ou com erro), um preset garante que a pessoa sempre receba um desafio.
            if let preset {
                finish(with: fallbackChallenge(from: preset), usedPreset: preset)
            } else {
                state = .failed(Self.message(for: error))
            }
        }
    }

    // MARK: - Generation

    /// Desafio 100% gerado: título, subtítulo e descrição.
    private func generatedChallenge(context: FrictionContext) async throws -> FrictionChallenge {
        guard availability == .available else { throw EngineError.modelUnavailable }

        var options = GenerationOptions()
        options.temperature = Double.random(in: 0..<1)

        let responseStream = takeSession().streamResponse(
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
        guard let title = latest?.title, let subTitle = latest?.subTitle, let rationale = latest?.rationale else {
            throw EngineError.incompleteResponse
        }
        return FrictionChallenge(title: title, subTitle: subTitle, rationale: rationale)
    }

    /// Preset: `subTitle` e `rationale` vêm prontos, o modelo escreve só o título.
    private func titledChallenge(from preset: PresetChallenge, context: FrictionContext) async throws -> FrictionChallenge {
        guard availability == .available else { throw EngineError.modelUnavailable }

        var options = GenerationOptions()
        options.temperature = 0.5

        let response = try await takeSession().respond(
            to: titlePrompt(for: preset, context: context),
            generating: ChallengeTitle.self,
            options: options
        )

        let title = response.content.title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !title.isEmpty else { throw EngineError.incompleteResponse }
        return FrictionChallenge(title: title, subTitle: preset.subTitle, rationale: preset.rationale)
    }

    /// Sem o modelo, o nome curto do preset serve de título.
    private func fallbackChallenge(from preset: PresetChallenge) -> FrictionChallenge {
        FrictionChallenge(title: preset.subTitle, subTitle: preset.subTitle, rationale: preset.rationale)
    }

    private func finish(with challenge: FrictionChallenge, usedPreset: PresetChallenge?) {
        seenTitles.append(challenge.title)
        if let usedPreset { seenPresets.insert(usedPreset.rationale) }
        state = .finished(challenge)
    }

    // MARK: - Presets

    /// Escolhe um preset da categoria que não esteja arquivado, preferindo os ainda não vistos.
    private func nextPreset(for context: FrictionContext) -> PresetChallenge? {
        let archived = Set(context.archivedDescriptions)
        let available = PresetCatalog.challenges(for: context.category)
            .filter { !archived.contains($0.rationale) }
        let unseen = available.filter { !seenPresets.contains($0.rationale) }
        return (unseen.isEmpty ? available : unseen).randomElement()
    }

    // MARK: - Prompts

    private func fullPrompt(for context: FrictionContext) -> String {
        var lines = [
            "categoria: \(context.category.focus)",
            "Crie um desafio novo para essa categoria."
        ]

        let examples = PresetCatalog.challenges(for: context.category).shuffled().prefix(2)
        if !examples.isEmpty {
            lines.append("Exemplos do estilo esperado (não copie):")
            lines += examples.map { "- \($0.subTitle): \($0.rationale)" }
        }

        lines += avoidLines(for: context)
        return lines.joined(separator: "\n")
    }

    private func titlePrompt(for preset: PresetChallenge, context: FrictionContext) -> String {
        """
        categoria: \(context.category.focus)
        nome do desafio: \(preset.subTitle)
        descrição: \(preset.rationale)
        Escreva só a frase curta para o círculo, sem repetir os títulos já vistos.
        \(avoidLines(for: context).joined(separator: "\n"))
        """
    }

    /// Lista os desafios já vistos (arquivados e desta sessão), limitada para não estourar o contexto.
    private func avoidLines(for context: FrictionContext) -> [String] {
        let avoided = (context.archivedTitles + seenTitles).suffix(20)
        guard !avoided.isEmpty else { return [] }
        return ["Não repita nem se aproxime destes desafios já vistos:"] + avoided.map { "- \($0)" }
    }

    // MARK: - Session setup

    /// Usa a sessão aquecida, se houver. Cada desafio usa uma sessão nova para o histórico não crescer.
    private func takeSession() -> LanguageModelSession {
        defer { session = nil }
        return session ?? makeSession()
    }

    private func makeSession() -> LanguageModelSession {
        LanguageModelSession(model: .default, instructions: frictionInstructions)
    }

    private static func message(for error: Error) -> String {
        if let engineError = error as? EngineError {
            switch engineError {
            case .modelUnavailable:
                return "Não foi possível gerar um desafio agora. Verifique se a Apple Intelligence está ativada em Ajustes."
            case .incompleteResponse:
                return "O desafio veio incompleto. Tente novamente."
            }
        }

        if #available(iOS 27.0, macOS 27.0, visionOS 27.0, *), let modelError = error as? LanguageModelError {
            switch modelError {
            case .contextSizeExceeded:
                return "A conversa ficou grande demais. Tente novamente."
            case .guardrailViolation:
                return "Não foi possível criar esse desafio por motivos de segurança. Tente novamente."
            case .unsupportedLanguageOrLocale:
                return "O idioma atual não é compatível com o modelo neste aparelho."
            case .rateLimited:
                return "Muitos pedidos em pouco tempo. Aguarde um instante e tente de novo."
            case .refusal:
                return "O modelo não conseguiu criar um desafio. Tente novamente."
            default:
                return "Não foi possível gerar o desafio agora."
            }
        }

        if #available(iOS 27.0, macOS 27.0, visionOS 27.0, *), let systemError = error as? SystemLanguageModel.Error {
            switch systemError {
            case .assetsUnavailable:
                return "O modelo ainda está sendo preparado neste aparelho, ou a Apple Intelligence está desativada. Verifique os Ajustes e tente novamente."
            @unknown default:
                return "Não foi possível gerar o desafio agora."
            }
        }

        // iOS 26 (antes de existir o LanguageModelError) lança este tipo.
        if let generationError = error as? LanguageModelSession.GenerationError {
            switch generationError {
            case .exceededContextWindowSize:
                return "A conversa ficou grande demais. Tente novamente."
            case .guardrailViolation:
                return "Não foi possível criar esse desafio por motivos de segurança. Tente novamente."
            case .unsupportedLanguageOrLocale:
                return "O idioma atual não é compatível com o modelo neste aparelho."
            case .rateLimited:
                return "Muitos pedidos em pouco tempo. Aguarde um instante e tente de novo."
            case .refusal:
                return "O modelo não conseguiu criar um desafio. Tente novamente."
            case .assetsUnavailable:
                return "O modelo ainda está sendo preparado neste aparelho. Tente novamente em breve."
            case .decodingFailure, .unsupportedGuide:
                return "O desafio veio em um formato inesperado. Tente novamente."
            @unknown default:
                return "Não foi possível gerar o desafio agora."
            }
        }

        if error.localizedDescription.localizedCaseInsensitiveContains("asset") {
            return "O modelo do aparelho não está disponível agora. Verifique se a Apple Intelligence está ativada, se o aparelho não está no Modo de Pouca Energia, e tente de novo."
        }

        return "Não foi possível gerar o desafio agora."
    }
}
