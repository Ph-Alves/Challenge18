//
//  WatchInteractor.swift
//  ChallengeFinalWatch Watch App
//
//  Created by Paulo Henrique Costa Alves on 19/11/26.
//

import Foundation

// MARK: - Protocol

/// O que as Views enxergam do Interactor: só as AÇÕES que o usuário pode fazer.
///
/// Com o protocolo, a View não depende da classe concreta. Nos testes e nos
/// `#Preview`, dá para passar um Interactor falso que só anota os toques.
@MainActor
protocol WatchInteractorProtocol: AnyObject {
    // MARK: Navigation
    func startActivity()
    func finishDraw()
    func acceptChallenge()
    func startTimer()
    func finishActivity()
    func returnToHome()
    func didTapBack(on step: WatchStep)
    func didTapClose()

    // MARK: Desafio (presets)
    func drawChallenge(for category: WatchCategory)
    func rerollChallenge(for category: WatchCategory)
    func generateAchievement(elapsed: TimeInterval)
}

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

// MARK: - Class

/// O "cérebro" do Watch.
///
/// Decide o que acontece em cada ação do usuário e avisa o Presenter.
/// Tem a navegação entre os steps e o sorteio dos desafios, que vêm só dos presets
/// (no Watch não há geração pelo modelo).
@MainActor
final class WatchInteractor: WatchInteractorProtocol {

    // MARK: - Dependências

    /// Para quem o Interactor manda os resultados. Pelo protocolo, para dar spy nos testes.
    let presenter: WatchPresenterProtocol

    // MARK: - Dados do fluxo

    /// Preset sorteado agora. É dele que sai a conquista.
    private(set) var currentPreset: PresetChallenge?

    /// Presets já mostrados nesta sessão (pelo `rationale`), para o "outro desafio" não repetir.
    private var seenPresets: Set<String> = []

    // MARK: - Init

    init(presenter: WatchPresenterProtocol) {
        self.presenter = presenter
    }

    // MARK: - Navigation

    /// Toque no círculo da categoria na home: vai para o sorteio.
    func startActivity() {
        presenter.presentDraw()
    }

    /// O sorteio terminou (o relógio foi sacudido): mostra o "topa?".
    func finishDraw() {
        presenter.presentChallenge()
    }

    /// "aceitar": mostra o desafio aceito.
    func acceptChallenge() {
        presenter.presentAccepted()
    }

    /// "iniciar": começa o cronômetro.
    func startTimer() {
        presenter.presentInProgress()
    }

    /// Botão de parar o cronômetro: vai para o "arrasou".
    func finishActivity() {
        presenter.presentCompleted()
    }

    /// "home" no "arrasou": volta para o seletor de categoria.
    func returnToHome() {
        presenter.presentHome()
    }

    /// Seta de voltar (steps `.draw` e `.challenge`).
    /// Aqui eu to definindo quem "deve voltar" pra quem.
    func didTapBack(on step: WatchStep) {
        switch step {
        case .draw:
            presenter.presentHome()      // volta pro seletor
        case .challenge:
            presenter.presentDraw()      // volta pro sorteio
        case .home, .accepted, .inProgress, .completed:
            break  // esses steps não têm seta
        }
    }

    /// X (steps `.accepted` e `.inProgress`): sai do fluxo e volta para a home.
    func didTapClose() {
        presenter.presentHome()
    }

    // MARK: - Desafio (presets)
    //
    // Cópia do fluxo do `FoundationWorker` do iOS, só com os presets:
    // sorteia um desafio ainda não visto e, ao terminar, monta a conquista com o tempo.
    // Estas funções só entregam os dados ao Presenter; a troca de step continua nas de navegação acima.

    /// Sorteia um desafio da categoria, sem repetir os já vistos nesta sessão.
    func drawChallenge(for category: WatchCategory) {
        guard let preset = nextPreset(for: category) else { return }

        currentPreset = preset
        seenPresets.insert(preset.rationale)
        presenter.presentDrawnChallenge(
            WatchChallenge(
                title: preset.title.fitted(to: TitleLimit.challenge),
                subTitle: preset.subTitle,
                rationale: preset.rationale
            )
        )
    }

    /// "outro desafio": sorteia de novo na mesma categoria.
    func rerollChallenge(for category: WatchCategory) {
        drawChallenge(for: category)
    }

    /// Conquista do desafio sorteado, citando o tempo do cronômetro.
    /// Sem desafio sorteado não há conquista, então não faz nada.
    func generateAchievement(elapsed: TimeInterval) {
        guard let preset = currentPreset else { return }

        let duration = Self.spokenDuration(elapsed)
        presenter.presentAchievement(
            WatchAchievement(
                title: preset.achievement.title.fitted(to: TitleLimit.achievement),
                description: preset.achievement.description(duration: duration)
            )
        )
    }

    // MARK: - Auxiliares privados (presets)

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
