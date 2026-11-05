//
//  ActivityInteractor.swift
//  ChallengeFinal
//
//  Created by Raquel Souza on 19/10/26.
//

import Foundation
import FoundationModels
import PhotosUI
import SwiftUI

// MARK: - Snapshot
/// Struct para salvar o estado temporário
struct TemporaryData: Codable {
    var step: ActivityStep
    var category: ActivityCategory
    var activityID: UUID
    var resultID: UUID
    var title: String
    var subtitle: String
    var description: String
    var achievementTitle: String
    var achievementDescription: String
    var savedAt: Date
    
    init(step: ActivityStep, category: ActivityCategory, activityID: UUID, resultID: UUID, title: String, subtitle: String, description: String, achievementTitle: String, achievementDescription: String, savedAt: Date) {
        self.step = step
        self.category = category
        self.activityID = activityID
        self.resultID = resultID
        self.title = title
        self.subtitle = subtitle
        self.description = description
        self.achievementTitle = achievementTitle
        self.achievementDescription = achievementDescription
        self.savedAt = savedAt
    }
}

extension TemporaryData {
    /// Chave do snapshot no `UserDefaults`.
    static let key = "activity.temporaryData"

    /// Quanto tempo o snapshot vale. Passou disso, é descartado.
    static let lifetime: TimeInterval = 60 * 60

    /// Devolve o snapshot se existir e ainda for válido. Não apaga nada:
    /// a Home usa para decidir se reabre o fluxo, antes de o Interactor existir.
    static func load(from defaults: UserDefaults = .standard) -> TemporaryData? {
        guard let data = defaults.data(forKey: key),
              let snapshot = try? JSONDecoder().decode(TemporaryData.self, from: data),
              Date().timeIntervalSince(snapshot.savedAt) < lifetime else {
            return nil
        }
        return snapshot
    }
}

// MARK: - Protocol

/// O que as Views enxergam do Interactor: só as AÇÕES que o usuário pode fazer.
///
/// Com o protocolo, a View não depende da classe concreta. Nos testes e nos
/// `#Preview`, dá para passar um Interactor falso que só anota os toques.
protocol ActivityInteractorProtocol: AnyObject {
    // MARK: Step .inProgress
    func startTimer()
    func stopTimer()
    func cancelTimer()

    // MARK: Step .draw
    func detectMotion(for category: ActivityCategory)
    func finishDetection()
    func prepare(for category: ActivityCategory)
    func archiveActivity(title: String, description: String, in category: ActivityCategory)
    func reroll(for category: ActivityCategory)
    func raffle(for category: ActivityCategory)

    // MARK: Step .mood
    func nextHumor()
    func previousHumor()

    // MARK: Step .photo
    func openCamera()
    func retakePhoto()
    func closeCamera()
    func toggleFlash()
    func switchCamera()
    func takePhoto()
    func didSelectFromGallery(_ item: PhotosPickerItem)
    func continueFromPhoto()
    func dismissAlerts()
    func cacheData(title: String, subtitle: String, description: String)

    // MARK: Step .summary
    func loadSummary(title: String?, subtitle: String?, description: String?)
    func shareStory(_ image: UIImage?)
    func didFinishSharing(completed: Bool)

    // MARK: Navigation
    func acceptActivity()
    func startActivity()
    func goToActivityDetail()
    func returnToStart()
    func completeActivity(currentCategory: ActivityCategory, title: String, subTitle: String, Description: String)
    func selectMood(humor: Humor)
    func finishActivityFlow()
}

/// Erro ao carregar uma foto da galeria.
enum PhotoLibraryError: Error {
    /// O item escolhido não devolveu os bytes da imagem.
    case loadFailed
}

// MARK: - Class

/// O "cérebro" do fluxo de Activity.
///
/// Decide o que acontece em cada ação do usuário, guarda os dados do fluxo
/// (desafio, humor, foto, tempo...), usa os Workers para o trabalho pesado
/// e avisa o Presenter do resultado. A navegação entre steps passa pelo
/// Presenter -> Store -> Coordinator.
///
/// Organização (tudo neste arquivo): dependências, dados do fluxo, init,
/// navegação e uma seção para cada step (`.inProgress`, `.draw`, `.mood`,
/// `.photo` e `.summary`).
@MainActor
final class ActivityInteractor: ActivityInteractorProtocol {

    // MARK: - Dependências

    /// Para quem o Interactor manda os resultados. Pelo protocolo, para dar spy nos testes.
    let presenter: ActivityPresenterProtocol

    let camera: CameraWorkerProtocol

    let activityRepository: GenericRepository<Activity>

    /// Grava a imagem do story em PNG para o share sheet.
    let share: ShareWorkerProtocol

    var hapticWorker: HapticsWorkerProtocol

    var coreMotionWorker: CoreMotionWorkerProtocol
    /// Worker responsável pelas operações do foundation
    var foundationWorker: FoundationWorkerProtocol

    /// O cronômetro: só entrega os ticks de 1 segundo. Pelo protocolo, para dar mock nos testes.
    let timer: TimerWorkerProtocol

    /// A Live Activity (Dynamic Island) do cronômetro. Pelo protocolo, para dar mock nos testes.
    /// Quem fala com ela é o Interactor direto, sem passar pelo Presenter: é algo do sistema,
    /// não da tela do app.
    let liveActivity: WidgetWorkerProtocol

    // MARK: - Dados do fluxo

    /// Humor escolhido no step `.mood`.
    /// TODO: preencher quando o `.mood` for implementado.
    var selectedHumor: Humor?

    /// Foto escolhida no step `.photo` (câmera ou galeria).
    /// `nil` = o usuário continuou sem foto. Vai para o `ActivityResult` no final.
    var selectedPhoto: Data?

    /// Se o flash está ligado na tela da câmera.
    var isFlashOn = false

    /// Instância da atividade criada (vai ser atualizada a partir de humor pra frente)
    /// depois de ir atualizando, o banco responde a mudança.
    var currentActivity: Activity?

    /// O resultado do desafio, montado ao chegar no `.summary`.
    /// É dele que sai a foto do story, e é ele que deve ser salvo no banco.
    var result: ActivityResult?

    /// Quando o cronômetro foi iniciado. `nil` = parado.
    /// O tempo é sempre calculado a partir desta data, nunca contado de 1 em 1.
    var timerStartDate: Date?

    /// Tempo final da atividade, em segundos, fixado ao terminar (`stopTimer`).
    /// Vai para o `ActivityResult` no final. Volta a 0 se o usuário cancelar.
    var timerElapsed: TimeInterval = 0

    /// O Task que escuta os ticks do worker. Fica guardado para poder ser cancelado.
    var timerTask: Task<Void, Never>?

    /// Conquista gerada ao terminar o cronômetro. Fica `nil` até o modelo responder.
    var achievement: Achievement?

    /// O Task que gera a conquista. Fica guardado para poder ser cancelado.
    var achievementTask: Task<Void, Never>?

    /// Grupo da atividade (mente, movimento, sentidos ou conexão), escolhido na Home.
    /// Não muda durante o fluxo, por isso entra no init em vez de ser passado a cada ação.
    /// Aparece na Live Activity.
    let category: ActivityCategory

    // Estado do sorteio (usado na seção do step .draw)
    var shakeWasStrongEnough = false
    var shakeIdleTimer: Timer?
    let motionFeedbackThreshold: Double = 0.3
    var isRaffling: Bool = false

    // MARK: - Init

    init(presenter: ActivityPresenterProtocol,
         activityRepository: GenericRepository<Activity>,
         hapticWorker: HapticsWorkerProtocol,
         coreMotionWorker: CoreMotionWorkerProtocol,
         foundationWorker: FoundationWorkerProtocol,
         camera: CameraWorkerProtocol,
         share: ShareWorkerProtocol,
         timer: TimerWorkerProtocol,
         liveActivity: WidgetWorkerProtocol,
         currentCategory: ActivityCategory
        ) {
        self.presenter = presenter
        self.activityRepository = activityRepository
        self.hapticWorker = hapticWorker
        self.coreMotionWorker = coreMotionWorker
        self.foundationWorker = foundationWorker
        self.camera = camera
        self.share = share
        self.timer = timer
        self.liveActivity = liveActivity
        self.category = currentCategory
    }
    
    // MARK: - Restauração
    //
    // Ao mudar a permissão da câmera nos Ajustes, o iOS pode encerrar o app.
    // Antes de sair, guardamos o necessário para voltar ao step `.photo`.

    /// Onde o snapshot é guardado. Fica como variável para os testes usarem um `UserDefaults` isolado.
    var defaults: UserDefaults = .standard

    /// Guarda o estado do fluxo no `UserDefaults`. Chame ANTES de abrir os Ajustes.
    ///
    /// Os textos do desafio vêm da View porque só a Store os tem. O resto o Interactor já
    /// conhece: a `Activity` e o `ActivityResult` estão no banco, então guardamos só os IDs.
    func cacheData(title: String, subtitle: String, description: String) {
        guard let currentActivity, let result else { return }

        let snapshot = TemporaryData(
            step: .photo,
            category: category,
            activityID: currentActivity.activityID,
            resultID: result.resultID,
            title: title,
            subtitle: subtitle,
            description: description,
            achievementTitle: achievement?.title ?? result.achievementTitle,
            achievementDescription: achievement?.description ?? result.achievementDescription,
            savedAt: Date()
        )

        do {
            let data = try JSONEncoder().encode(snapshot)
            defaults.set(data, forKey: TemporaryData.key)
        } catch {
            print("Erro ao salvar o estado temporário: \(error.localizedDescription)")
        }
    }

    /// Lê o snapshot, devolve o estado ao Interactor e o apaga (vale uma restauração só).
    ///
    /// O que não é do Interactor vai pelo Presenter: os textos do desafio (Store) e o
    /// step `.photo` (Coordinator). Se não há snapshot, ele expirou ou a atividade
    /// não existe mais, não faz nada.
    func restoreData() {
        defer { defaults.removeObject(forKey: TemporaryData.key) }

        guard let snapshot = TemporaryData.load(from: defaults) else { return }

        do {
            guard let activity = try activityRepository.getAll().first(where: { $0.activityID == snapshot.activityID }),
                  let restoredResult = activity.result,
                  restoredResult.resultID == snapshot.resultID else {
                return
            }

            currentActivity = activity
            result = restoredResult
            selectedHumor = restoredResult.humor
            timerElapsed = restoredResult.time

            // Sem isso o `continueFromPhoto()` não navega (ele exige `achievement`).
            achievement = Achievement(title: snapshot.achievementTitle, description: snapshot.achievementDescription)

            // Os textos entram na Store ANTES da troca de step, para o step já abrir completo.
            presenter.presentHumor(restoredResult.humor)
            presenter.presentRestoredChallenge(
                title: snapshot.title,
                subtitle: snapshot.subtitle,
                description: snapshot.description)
            presenter.presentPhoto()
        } catch {
            print("Erro ao restaurar o estado: \(error.localizedDescription)")
        }
    }

    // MARK: - Navigation
    //
    // Por enquanto só pedem ao Presenter para trocar de step.
    // A regra de cada step (sorteio, tempo, humor...) fica nas seções abaixo.

    /// Aceitou o desafio sorteado: continua no step `.challenge`,
    /// que passa a mostrar a tela de desafio aceito.
    func acceptActivity() {
        presenter.presentAcceptedActivity()
    }

    /// Começou a executar o desafio: também vai para "em andamento".
    func startActivity() {
        startTimer()
        presenter.presentInProgress()
    }

    /// Abre os detalhes do desafio.
    func goToActivityDetail() {
        presenter.presentActivityStep()
    }

    /// Volta para o sorteio, limpando o desafio anterior.
    func returnToStart() {
        presenter.presentStartAgain()
    }

    /// Terminou o desafio: vai para o humor.
    func completeActivity(currentCategory: ActivityCategory, title: String, subTitle: String, Description: String) {
        do {
            self.currentActivity = Activity(category: currentCategory, result: nil, name: title, description: subTitle, archived: false)
            if let currentActivity {
                try activityRepository.add(currentActivity)
            }
        } catch {
            print("Erro ao adicionar entidade: \(error.localizedDescription)")
        }
        stopTimer()
        presenter.presentMood()
    }

    /// Escolheu o humor: vai para a foto.
    func selectMood(humor: Humor) {
        do {
            selectedHumor = humor
            let result = makeResultIfNeeded()
            result.humor = humor
            currentActivity?.result = result
            try activityRepository.save()
        } catch {
            print("Erro ao salvar o banco: \(error.localizedDescription)")
        }
        presenter.presentPhoto()
    }

    /// Termina o fluxo e volta para a Home.
    func finishActivityFlow() {
        do {
            self.currentActivity = nil
            self.result = nil
            try activityRepository.save()
        } catch {
            print("Erro ao salvar o banco: \(error.localizedDescription)")
        }
        cancelTimer()
        // O fluxo acabou: um snapshot que sobrou (voltou dos Ajustes sem o app morrer) não vale mais.
        defaults.removeObject(forKey: TemporaryData.key)
        presenter.presentFlowFinished()
    }

    // MARK: - Step .inProgress (cronômetro)
    //
    // Ações do cronômetro da atividade em andamento.
    //
    // O tempo NÃO é um contador (`segundos += 1`): guarda só a data de início
    // (`timerStartDate`) e calcula "agora - início" quando precisa. Assim o
    // valor continua certo mesmo se o app for para o background.
    // O `TimerWorker` só entrega os "ticks" (um por segundo) que mandam a tela
    // atualizar; ele não conta nada.

    /// Começa a contar: guarda a data de início e, a cada tick, manda o tempo
    /// atual para o Presenter (que formata e entrega à Store).
    func startTimer( ) {
        // Garante um só Task rodando, caso o início seja chamado duas vezes.
        timerTask?.cancel()
        let startDate = Date()
        timerStartDate = startDate

        // Liga a Live Activity (Dynamic Island) com a MESMA data do cronômetro do app e o grupo
        // da atividade (`category.text`). O `Task` é necessário porque o worker é `async`.
        Task { await liveActivity.startLiveActivity(name: category.text, startDate: startDate) }

        // O Task é necessário porque o `for await` só roda em contexto assíncrono.
        // Fica guardado em `timerTask` para podermos cancelar depois.
        // `[weak self]` evita que o Task segure o Interactor vivo para sempre.
        timerTask = Task { [weak self] in
            guard let ticks = self?.timer.ticks() else { return }

            // Espera cada tick do worker (1 por segundo) e só então atualiza a tela.
            for await _ in ticks {
                guard let self else { return }
                presenter.presentTime(currentElapsed())
            }
        }
    }

    /// Terminou a atividade: para os ticks e fixa o tempo final em `timerElapsed`,
    /// que vai para o `ActivityResult` no final do fluxo.
    func stopTimer() {
        timerTask?.cancel()
        timerElapsed = currentElapsed()
        timerStartDate = nil

        // A ilha passa a mostrar o tempo final (parado) e some depois de alguns segundos.
        Task { await liveActivity.stopLiveActivity(elapsed: timerElapsed)}

        generateAchievement()
    }

    /// Pede a conquista ao modelo em segundo plano, enquanto o usuário escolhe humor e foto.
    /// Quando chega, vai para o `ActivityResult` (ou espera por ele, se ainda não existir).
    private func generateAchievement() {
        guard let activity = currentActivity else { return }
        let elapsed = timerElapsed

        achievementTask?.cancel()
        achievementTask = Task { [weak self] in
            guard let self else { return }
            let generated = await foundationWorker.generateAchievement(for: activity, elapsed: elapsed)
            guard !Task.isCancelled else { return }
            applyAchievement(generated)
        }
    }

    /// Guarda a conquista no Interactor e, se o `ActivityResult` já existir (o usuário já
    /// escolheu o humor), grava nele também. Se ainda não existir, o `makeResultIfNeeded()`
    /// copia `achievement` quando criar o result.
    private func applyAchievement(_ generated: Achievement) {
        achievement = generated
        guard let result else { return }

        do {
            result.achievementTitle = generated.title
            result.achievementDescription = generated.description
            try activityRepository.save()
        } catch {
            print("Erro ao salvar o banco: \(error.localizedDescription)")
        }
    }

    /// Cancelou a atividade: para os ticks e descarta o tempo (nada é salvo).
    /// A tela volta a "00:00:00".
    func cancelTimer() {
        timerTask?.cancel()
        timerTask = nil
        achievementTask?.cancel()
        achievementTask = nil
        achievement = nil
        timerStartDate = nil
        timerElapsed = 0
        presenter.presentTime(0)

        // Encerra a ilha na hora, sem mostrar o tempo (nada foi concluído).
        Task { await liveActivity.cancelLiveActivity()}
    }

    /// Quanto tempo já passou desde `timerStartDate`, em segundos.
    /// Devolve `0` se o cronômetro não estiver rodando.
    func currentElapsed() -> TimeInterval {
        guard let start = timerStartDate else { return 0}
        return Date().timeIntervalSince(start)
    }

    // MARK: - Step .draw
    //
    // Ações da tela de sorteio: detectar o chacoalhar, gerar o desafio
    // com o FoundationWorker e arquivar desafios.

    // MARK: Detecção do chacoalhar

    /// A tela de sorteio apareceu: começa a ouvir o acelerômetro.
    ///
    /// Liga três coisas:
    /// 1. O acelerômetro (CoreMotion), que avisa a força de cada movimento.
    /// 2. O haptic contínuo, que vibra junto com o chacoalhar.
    /// 3. Um timer que percebe quando a pessoa parou, para encerrar o haptic.
    ///
    /// Quem encerra isso é o `finishDetection()`, quando a tela some.
    func detectMotion(for category: ActivityCategory) {
        self.hapticWorker.prepareHaptics()

        // O sorteio só acontece quando o haptic contínuo para por inatividade
        // (pessoa parou de sacudir) e, durante o movimento, a intensidade
        // chegou a cruzar o shakeThreshold — evita sortear com tremores leves.
        self.hapticWorker.onShakeSessionEnded = {
            guard self.shakeWasStrongEnough else { return }
            self.shakeWasStrongEnough = false
            self.raffle(for: category)
        }
        // Haptic contínuo: toca enquanto a variação do acelerômetro estiver
        // acima do threshold, com intensidade proporcional à força do movimento.
        self.coreMotionWorker.onMotionUpdate = { delta in
            guard delta > self.motionFeedbackThreshold else { return }
            self.hapticWorker.startShakeLoop()
            let normalized = min(delta / self.coreMotionWorker.shakeThreshold, 1.0)
            self.hapticWorker.updateShakeIntensity(normalized)
            if delta > self.coreMotionWorker.shakeThreshold {
                self.shakeWasStrongEnough = true
            }
        }

        self.coreMotionWorker.startMonitoring()

        // Como não há um evento de "parou de sacudir", verificamos periodicamente
        // se faz tempo que não chega leitura acima do threshold e paramos o haptic.
        shakeIdleTimer?.invalidate()
        shakeIdleTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            // O closure do Timer é Sendable; o timer foi agendado na main run loop,
            // então podemos assumir o isolamento do MainActor para acessar o worker.
            MainActor.assumeIsolated {
                self?.hapticWorker.stopShakeLoopIfIdle(timeout: 0.25)
            }
        }
    }

    // MARK: Preparação e arquivo

    /// "Aquece" o modelo de linguagem para a categoria, assim o sorteio responde mais rápido.
    /// Só faz algo se o Foundation Models estiver disponível no aparelho.
    func prepare(for category: ActivityCategory) {
        if foundationWorker.availability == .available {
            foundationWorker.prewarm(for: category)
        }
    }

    /// "Arquivar desafio da lista": salva o desafio como `archived`.
    /// O sorteio usa os arquivados para não repetir esse tipo de desafio.
    func archiveActivity(title: String, description: String, in category: ActivityCategory) {
        let activity = Activity(category: category, result: nil, name: title, description: description, archived: true)
        do {
            try activityRepository.add(activity)
            prepare(for: category)
        } catch {
            print("Erro ao adicionar elemento: \(error.localizedDescription)")
        }
    }

    /// Sorteia outro desafio sem precisar chacoalhar de novo.
    func reroll(for category: ActivityCategory) {
        raffle(for: category)
    }

    /// A tela de sorteio saiu: desliga acelerômetro, timer e haptic.
    /// Sem isso o celular continuaria vibrando em outros steps.
    func finishDetection() {
        coreMotionWorker.stopMonitoring()
        shakeIdleTimer?.invalidate()
        shakeIdleTimer = nil
        hapticWorker.stopShakeLoop()
    }

    /// Gera o desafio com o Foundation Models, em 3 passos:
    /// 1. Avisa o Presenter que está procurando (a tela troca o texto).
    /// 2. Pede ao worker um desafio, passando os arquivados para ele evitar.
    /// 3. Entrega o resultado: o desafio pronto ou "falhou".
    func raffle(for category: ActivityCategory) {
        Task {
            isRaffling = true
            presenter.presentSearching()
            do {
                let archived: [Activity] = try activityRepository.getAll().filter(\.archived)
                await foundationWorker.generate(for: category, archived: archived)
            } catch {
                print("Erro em buscar atividades: \(error.localizedDescription)")
            }

            switch foundationWorker.state {
            case .finished(let challenge):
                presenter.presentActivity(challenge)
            case .failed(let message):
                print("Erro: \(message)")
                presenter.presentSearchFailed()
            default:
                presenter.presentSearchFailed()
            }
            isRaffling = false
        }
    }

    // MARK: - Step .mood
    //
    // O humor escolhido fica em `selectedHumor` (vai para o `ActivityResult`
    // no resumo). O "continuar" é o `selectMood()`, na seção de navegação.

    /// Swipe para a esquerda: o humor da direita vem para o topo.
    func nextHumor() {
        moveHumor(by: 1)
    }

    /// Swipe para a direita: o humor da esquerda vem para o topo.
    func previousHumor() {
        moveHumor(by: -1)
    }

    // MARK: - Step .photo
    //
    // Ações das telas "sorria! você será fotografado" e da câmera.
    //
    // Padrão de todas as ações:
    // 1. Decide o que fazer (regra de negócio).
    // 2. Usa o worker, se precisar.
    // 3. Avisa o Presenter do resultado (nunca mexe na Store direto).
    //
    // As completions do worker já chegam na main thread,
    // então dá para chamar o Presenter direto.

    // MARK: Abrir e fechar a câmera

    /// Toque em "tire uma foto!".
    ///
    /// A permissão é verificada AQUI, e não ao abrir o step: quem só quer
    /// importar da galeria ou continuar sem foto nunca vê o pedido de câmera.
    ///
    /// Perguntamos ao worker toda vez (sem guardar a resposta) porque o
    /// usuário pode ter mudado a permissão nos Ajustes no meio do caminho.
    func openCamera() {
        switch camera.permissionStatus() {
        case .authorized:
            startCamera()

        case .notDetermined:
            // Primeira vez: o sistema mostra o pedido de permissão.
            camera.requestPermission { [weak self] granted in
                guard let self else { return }

                if granted {
                    self.startCamera()
                } else {
                    self.presenter.presentPermissionDenied()
                }
            }

        case .denied:
            presenter.presentPermissionDenied()
        }
    }

    /// Toque em "tirar outra foto".
    ///
    /// A foto anterior continua em `selectedPhoto` até chegar uma nova.
    /// Se o usuário fechar a câmera sem fotografar, ele não perde a que tinha.
    func retakePhoto() {
        openCamera()
    }

    /// O usuário fechou a câmera sem tirar foto.
    func closeCamera() {
        camera.stopSession()
        presenter.presentCameraClosed()
    }

    // MARK: Controles da câmera

    /// Toque no botão de flash.
    func toggleFlash() {
        isFlashOn.toggle()
        presenter.presentFlash(isOn: isFlashOn)
    }

    /// Toque no botão de trocar câmera.
    /// Não muda nada na Store: o preview se atualiza sozinho.
    func switchCamera() {
        camera.switchCamera { [weak self] result in
            guard let self else { return }

            do {
                try result.get()
            } catch {
                self.presenter.presentError(error)
            }
        }
    }

    /// Toque no botão de disparo.
    func takePhoto() {
        camera.capturePhoto(flash: isFlashOn) { [weak self] result in
            guard let self else { return }

            do {
                let data = try result.get()
                self.didReceivePhoto(data)
            } catch {
                self.presenter.presentError(error)
            }
        }
    }

    // MARK: Galeria

    /// O usuário escolheu uma foto no PhotosPicker
    /// (pelo "importar da galeria" ou pelo "da biblioteca" na câmera).
    ///
    /// O picker devolve só uma "referência" (`PhotosPickerItem`).
    /// Os bytes precisam ser carregados, o que pode demorar (ex.: foto no iCloud).
    ///
    /// TODO(refatoração): mover o carregamento para um worker de galeria,
    /// assim o Interactor não precisa importar PhotosUI.
    func didSelectFromGallery(_ item: PhotosPickerItem) {
        _ = item.loadTransferable(type: Data.self) { [weak self] result in
            // O sistema responde numa fila qualquer: voltamos para a main.
            DispatchQueue.main.async {
                guard let self else { return }

                do {
                    guard let data = try result.get() else {
                        throw PhotoLibraryError.loadFailed
                    }
                    self.didReceivePhoto(data)
                } catch {
                    self.presenter.presentError(error)
                }
            }
        }
    }

    // MARK: Continuar e alertas

    /// Toque em "continuar" ou "continuar sem foto".
    ///
    /// A foto (ou `nil`) fica guardada em `selectedPhoto` para o resumo
    /// e para o `ActivityResult` no final do fluxo.
    func continueFromPhoto() {
        do {
            camera.stopSession()
            self.result?.photo = selectedPhoto
            self.currentActivity?.result = self.result
            try activityRepository.save()
        } catch {
            print("Erro ao salvar o banco: \(error.localizedDescription)")
        }
        // O summary só abre com a conquista pronta: ela vai para a Store junto com a transição.
        if let achievement {
            presenter.presentSummary(achievement: achievement)
        }
    }

    /// O usuário fechou um alerta (permissão negada ou erro).
    func dismissAlerts() {
        presenter.presentAlertsDismissed()
    }

    // MARK: - Step .summary
    //
    // Ações da tela "desafio finalizado": gerar o story e compartilhar.
    // O "finalizar" é o `finishActivityFlow()`, na seção de navegação.
    //
    // Fluxo do compartilhamento (VIP):
    // 1. `loadSummary(...)` recebe os textos do desafio (a View lê da Store) e
    //    manda ao Presenter junto com o resultado. O Presenter renderiza o story
    //    e guarda a imagem pronta na Store.
    // 2. Toque em "compartilhar": a View entrega essa imagem em `shareStory(_:)`.
    // 3. O `ShareWorker` grava o PNG; o Presenter abre o share sheet.
    // 4. O share sheet fecha: `didFinishSharing(completed:)`.

    // MARK: Resumo

    /// Chamado quando a tela de resumo aparece: gera a imagem do story.
    ///
    /// Os textos do desafio vêm da View, que os lê da Store
    /// (preenchidos no step `.draw`).
    func loadSummary(title: String?, subtitle: String?, description: String?) {
        presenter.presentStory(
            makeResultIfNeeded(),
            title: title,
            subtitle: subtitle,
            description: description
        )
    }

    // MARK: Compartilhar

    /// Toque em "compartilhar".
    ///
    /// Recebe a imagem que o Presenter já renderizou (está na Store).
    /// `nil` = a renderização falhou: mostramos o erro em vez de abrir um sheet vazio.
    func shareStory(_ image: UIImage?) {
        guard let image else {
            presenter.presentError(ShareError.renderFailed)
            return
        }

        do {
            let fileURL = try share.makeShareFile(from: image)
            presenter.presentShareSheet(fileURL: fileURL)
        } catch {
            presenter.presentError(error)
        }
    }

    /// O share sheet fechou (concluiu ou cancelou).
    func didFinishSharing(completed: Bool) {
        presenter.presentShareFinished(completed: completed)
    }

    // MARK: - Auxiliares

    /// Monta o `ActivityResult` com os dados do fluxo (só na primeira vez).
    ///
    /// Guardamos em `result` para que o story e o que for salvo no banco
    /// sejam sempre o MESMO objeto, mesmo se a tela aparecer de novo.
    func makeResultIfNeeded() -> ActivityResult {
        if let result {
            return result
        }

        let newResult = ActivityResult(
            photo: selectedPhoto,
            achievementTitle: achievement?.title ?? "",
            achievementDescription: achievement?.description ?? "",
            time: timerElapsed,
            humor: selectedHumor ?? .chill
        )

        result = newResult
        return newResult
    }

    // MARK: - Auxiliares privados (.mood)

    /// Anda `offset` posições na roleta, dando a volta nas pontas
    /// (depois do último vem o primeiro, e vice-versa).
    private func moveHumor(by offset: Int) {
        let humors = Humor.allCases
        let current = selectedHumor ?? .chill

        guard let index = humors.firstIndex(of: current) else { return }

        let newIndex = (index + offset + humors.count) % humors.count
        let humor = humors[newIndex]

        selectedHumor = humor
        presenter.presentHumor(humor)

        // Tique a cada fatia que passa pelo marcador.
        hapticWorker.playSelectionTick()
    }

    // MARK: - Auxiliares privados (.photo)

    /// Permissão OK: abre a tela da câmera e liga a sessão.
    private func startCamera() {
        // Mostra o estado atual do flash e abre a tela.
        // O preview fica preto por um instante até a sessão ligar.
        presenter.presentFlash(isOn: isFlashOn)
        presenter.presentCamera()

        camera.startSession { [weak self] result in
            guard let self else { return }

            do {
                try result.get()
            } catch {
                // A câmera não ligou: fecha a tela e mostra o erro.
                self.camera.stopSession()
                self.presenter.presentCameraClosed()
                self.presenter.presentError(error)
            }
        }
    }

    /// Caminho comum para foto da câmera e da galeria:
    /// daqui pra frente, as duas são iguais.
    private func didReceivePhoto(_ data: Data) {
        selectedPhoto = data
        camera.stopSession()
        presenter.presentCaptured(data)
    }
}
