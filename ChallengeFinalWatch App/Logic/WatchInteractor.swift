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
    func startActivity(category: WatchCategory)
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

    // MARK: Cronômetro
    func togglePause()
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

    /// O cronômetro: só entrega os ticks de 1 segundo. Pelo protocolo, para dar mock nos testes.
    let timer: WatchTimerWorkerProtocol

    // MARK: - Dados do fluxo

    /// Categoria escolhida na home. O sorteio do `finishDraw()` parte dela.
    private var selectedCategory: WatchCategory = .physical

    /// Preset sorteado agora. É dele que sai a conquista.
    private(set) var currentPreset: PresetChallenge?

    /// Presets já mostrados nesta sessão (pelo `rationale`), para o "outro desafio" não repetir.
    private var seenPresets: Set<String> = []

    /// Quando o cronômetro foi iniciado (ou retomado). `nil` = parado ou pausado.
    /// O tempo é sempre calculado a partir desta data, nunca contado de 1 em 1.
    private var timerStartDate: Date?

    /// Tempo já acumulado, em segundos. Fixado ao pausar ou parar; volta a 0 ao iniciar de novo.
    private var timerElapsed: TimeInterval = 0

    private var isTimerPaused = false

    /// O Task que escuta os ticks do worker. Fica guardado para poder ser cancelado.
    private var timerTask: Task<Void, Never>?

    // MARK: - Init

    init(presenter: WatchPresenterProtocol, timer: WatchTimerWorkerProtocol) {
        self.presenter = presenter
        self.timer = timer
    }

    // MARK: - Navigation

    /// Toque no círculo da categoria na home: guarda a categoria e vai para o sorteio.
    func startActivity(category: WatchCategory) {
        selectedCategory = category
        presenter.presentCategory(category)
        presenter.presentDraw()
    }

    /// O sorteio terminou (o relógio foi sacudido): sorteia o desafio da categoria e mostra o "topa?".
    func finishDraw() {
        drawChallenge(for: selectedCategory)
        presenter.presentChallenge()
    }

    /// "aceitar": mostra o desafio aceito.
    func acceptChallenge() {
        presenter.presentAccepted()
    }

    /// "iniciar": vai para "em andamento" e já começa o cronômetro do zero.
    func startTimer() {
        timerTask?.cancel()
        timerElapsed = 0
        isTimerPaused = false
        timerStartDate = Date()

        presenter.presentTime(0)
        presenter.presentPaused(false)
        startTicking()
        presenter.presentInProgress()
    }

    /// Botão de parar o cronômetro: fixa o tempo final e vai para o "arrasou".
    func finishActivity() {
        stopTimer()
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

    /// X (steps `.accepted` e `.inProgress`): sai do fluxo, descarta o cronômetro e volta para a home.
    func didTapClose() {
        cancelTimer()
        presenter.presentHome()
    }

    // MARK: - Cronômetro
    //
    // O tempo NÃO é um contador (`segundos += 1`): guarda a data de início (`timerStartDate`) e calcula
    // "agora - início" quando precisa. Assim o valor continua certo mesmo se o Watch apagar a tela.
    // O worker só entrega os ticks que mandam a tela atualizar; ele não conta nada.

    /// Botão da esquerda: alterna entre pausar e retomar.
    func togglePause() {
        if isTimerPaused { resumeTimer() } else { pauseTimer() }
    }

    /// Pausa: congela o tempo acumulado e para os ticks.
    private func pauseTimer() {
        guard timerStartDate != nil, !isTimerPaused else { return }

        timerElapsed = currentElapsed()
        isTimerPaused = true
        timerStartDate = nil
        timerTask?.cancel()

        presenter.presentTime(timerElapsed)
        presenter.presentPaused(true)
    }

    /// Retoma: desloca o início para que "agora - início" continue igual ao tempo acumulado.
    private func resumeTimer() {
        guard isTimerPaused else { return }

        timerStartDate = Date().addingTimeInterval(-timerElapsed)
        isTimerPaused = false

        presenter.presentPaused(false)
        startTicking()
    }

    /// Para os ticks e fixa o tempo final em `timerElapsed`. Pode ser chamado mais de uma vez
    /// sem zerar o tempo, porque só recalcula se o cronômetro ainda estiver rodando.
    private func stopTimer() {
        timerElapsed = currentElapsed()
        timerStartDate = nil
        isTimerPaused = false
        timerTask?.cancel()

        presenter.presentTime(timerElapsed)
        presenter.presentPaused(false)
    }

    /// Descarta o tempo (nada foi concluído) e volta a tela para "00:00:00".
    private func cancelTimer() {
        timerTask?.cancel()
        timerTask = nil
        timerStartDate = nil
        timerElapsed = 0
        isTimerPaused = false

        presenter.presentTime(0)
        presenter.presentPaused(false)
    }

    /// A cada tick do worker, manda o tempo atual para o Presenter.
    /// O `[weak self]` evita que o Task segure o Interactor vivo para sempre.
    private func startTicking() {
        timerTask?.cancel()
        timerTask = Task { [weak self] in
            guard let ticks = self?.timer.ticks() else { return }

            for await _ in ticks {
                guard let self else { return }
                presenter.presentTime(currentElapsed())
            }
        }
    }

    /// Quanto tempo já passou. Rodando, é "agora - início"; parado ou pausado, o valor fixado.
    private func currentElapsed() -> TimeInterval {
        guard let timerStartDate else { return timerElapsed }
        return Date().timeIntervalSince(timerStartDate)
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
