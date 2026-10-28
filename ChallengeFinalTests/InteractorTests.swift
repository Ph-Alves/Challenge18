//
//  InteractorTests.swift
//  ChallengeFinalTests
//
//  Created by Paulo Henrique Costa Alves on 19/10/26.
//

import Testing
import SwiftData
import Foundation
import FoundationModels
import UIKit
@testable import ChallengeFinal

// MARK: - Spies (test doubles for the Presenter protocols the Interactors talk to)

final class HomePresenterSpy: HomePresenterProtocol {
    
    private(set) var presentedCategory: ActivityCategory?
    private(set) var week: [Date]?
    
    func presentCategory(_ category: ChallengeFinal.ActivityCategory) {
        presentedCategory = category
    }
    
    func presentWeek(days: [Date]) {
        week = days
    }
    
    func presentActivityFlow() {
        
    }
}

/// Anota, em ordem, tudo que o Interactor pediu ao Presenter.
final class ActivityPresenterSpy: ActivityPresenterProtocol {
    
    enum Event: Equatable {
        case searching
        case searchFailed
        case challenge(title: String)
    }
    
    private(set) var events: [Event] = []

    // Cronômetro: guardados à parte de `events` para não misturar com os testes de sorteio.
    private(set) var presentedTimes: [TimeInterval] = []
    private(set) var inProgressCount = 0
    private(set) var moodCount = 0
    private(set) var flowFinishedCount = 0

    func presentTime(_ elapsed: TimeInterval) { presentedTimes.append(elapsed) }
    
    // Humor e compartilhamento
    private(set) var presentedHumors: [Humor] = []
    private(set) var presentedErrors: [Error] = []
    private(set) var storyCount = 0
    private(set) var shareSheetURL: URL?
    private(set) var shareFinished: Bool?

    // Sorteio
    func presentChallenge(_ challenge: FrictionChallenge) { events.append(.challenge(title: challenge.title)) }
    func presentSearching() { events.append(.searching) }
    func presentSearchFailed() { events.append(.searchFailed) }
    
    // Fora do escopo dos testes de sorteio
    func presentAcceptedActivity() {}
    func presentStartAgain() {}
    func presentMood() { moodCount += 1 }
    func presentPhoto() {}
    func presentCamera() {}
    func presentCameraClosed() {}
    func presentPermissionDenied() {}
    func presentCaptured(_ data: Data) {}
    func presentFlash(isOn: Bool) {}
    func presentAlertsDismissed() {}
    func presentSummary() {}
    func presentFlowFinished() { flowFinishedCount += 1 }
    func presentInProgress() { inProgressCount += 1 }
    func presentChallenge() {}
    func presentDraw() {}
    func presentActivity(_ challenge: ChallengeFinal.FrictionChallenge) { events.append(.challenge(title: challenge.title)) }
    func presentActivityStep() {}
    // Humor
    func presentHumor(_ humor: Humor) { presentedHumors.append(humor) }
    // Erros
    func presentError(_ error: Error) { presentedErrors.append(error) }
    // Resumo e compartilhamento
    func presentStory(_ result: ActivityResult, title: String?, subtitle: String?, description: String?) { storyCount += 1 }
    func presentShareSheet(fileURL: URL) { shareSheetURL = fileURL }
    func presentShareFinished(completed: Bool) { shareFinished = completed }
}

/// Foundation Models falso: devolve o estado que o teste mandar, sem usar o modelo do aparelho.
@MainActor
final class FoundationWorkerMock: FoundationWorkerProtocol {
    var state: FoundationWorkerState = .idle
    var availability: SystemLanguageModel.Availability = .available
    
    /// O que o worker vai terminar com depois de `generate`.
    var stateAfterGenerate: FoundationWorkerState = .finished(
        FrictionChallenge(title: "título", subTitle: "subtítulo", rationale: "descrição")
    )
    
    private(set) var prewarmedCategories: [ActivityCategory] = []
    private(set) var generateCalls: [(category: ActivityCategory, archived: [Activity])] = []
    
    func prewarm(for category: ActivityCategory) {
        prewarmedCategories.append(category)
    }
    
    func generate(for category: ActivityCategory, archived: [Activity]) async {
        generateCalls.append((category, archived))
        state = stateAfterGenerate
    }
}

final class HapticsWorkerMock: HapticsWorkerProtocol {
    var onShakeSessionEnded: (() -> Void)?
    
    private(set) var prepareCount = 0
    private(set) var startLoopCount = 0
    private(set) var intensities: [Double] = []
    private(set) var stopLoopCount = 0
    
    func prepareHaptics() { prepareCount += 1 }
    func startShakeLoop() { startLoopCount += 1 }
    func updateShakeIntensity(_ magnitude: Double) { intensities.append(magnitude) }
    func stopShakeLoopIfIdle(timeout: TimeInterval) {}
    func stopShakeLoop() { stopLoopCount += 1 }
}

final class CoreMotionWorkerMock: CoreMotionWorkerProtocol {
    var shakeThreshold: Double = 2.5
    var shakeCooldown: TimeInterval = 1.0
    var onMotionUpdate: ((Double) -> Void)?
    
    private(set) var startCount = 0
    private(set) var stopCount = 0
    
    func startMonitoring() { startCount += 1 }
    func stopMonitoring() { stopCount += 1 }
}

/// A câmera não participa do sorteio, mas o Interactor exige uma no init.
final class CameraWorkerMock: CameraWorkerProtocol {
    func permissionStatus() -> CameraPermission { .authorized }
    func requestPermission(completion: @escaping (Bool) -> Void) { completion(true) }
    func startSession(completion: @escaping (Result<Void, Error>) -> Void) { completion(.success(())) }
    func stopSession() {}
    func switchCamera(completion: @escaping (Result<Void, Error>) -> Void) { completion(.success(())) }
    func capturePhoto(flash: Bool, completion: @escaping (Result<Data, Error>) -> Void) { completion(.success(Data())) }
}

/// Worker de share falso: não grava arquivo de verdade.
/// Devolve uma URL fixa ou lança o erro configurado no teste.
final class ShareWorkerMock: ShareWorkerProtocol {
    var errorToThrow: Error?
    private(set) var receivedImage: UIImage?
    let url = URL(fileURLWithPath: "/tmp/Desafio-Concluído.png")

    func makeShareFile(from image: UIImage) throws -> URL {
        receivedImage = image
        if let errorToThrow { throw errorToThrow }
        return url
    }
}

/// Cronômetro falso: não espera 1 segundo de verdade. O teste decide quando o tick acontece
/// (`emitTick()`) e consegue ver quantas vezes o Interactor pediu ticks e quantos fluxos terminaram.
///
/// `@unchecked Sendable` porque o `onTermination` do `AsyncStream` é um closure `@Sendable`
/// que precisa escrever aqui; nos testes tudo roda na main thread.
final class TimerWorkerMock: TimerWorkerProtocol, @unchecked Sendable {
    private var continuation: AsyncStream<Void>.Continuation?

    private(set) var ticksCallCount = 0
    private(set) var terminationCount = 0

    func ticks() -> AsyncStream<Void> {
        ticksCallCount += 1
        return AsyncStream { continuation in
            self.continuation = continuation
            // Roda quando o Interactor cancela o Task que escuta os ticks.
            continuation.onTermination = { [weak self] _ in self?.terminationCount += 1 }
        }
    }

    /// Simula "passou 1 segundo" no fluxo mais recente.
    func emitTick() {
        continuation?.yield()
    }
}

/// Live Activity falsa: não abre a Dynamic Island de verdade. Só anota o que o Interactor pediu.
/// `@MainActor` porque o `WidgetWorkerProtocol` também é.
@MainActor
final class WidgetWorkerMock: WidgetWorkerProtocol {
    private(set) var startCalls: [(name: String, startDate: Date)] = []
    private(set) var stopElapsed: [TimeInterval] = []
    private(set) var cancelCount = 0

    func startLiveActivity(name: String, startDate: Date) async { startCalls.append((name, startDate)) }
    func stopLiveActivity(elapsed: TimeInterval) async { stopElapsed.append(elapsed) }
    func cancelLiveActivity() async { cancelCount += 1 }
}

//final class ProfilePresenterSpy: ProfilePresenterProtocol {
//    private(set) var presentedProfile: Profile?
//    func presentProfile(_ profile: Profile) {
//        presentedProfile = profile
//    }
//}

@Suite("Tests for all interactors in the project")
@MainActor
struct InteractorTests {

    // MARK: - Auxiliadores
    
    let modelContainer: ModelContainer = {
        let schema = Schema([Activity.self, ActivityResult.self, Profile.self])
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        return try! ModelContainer(for: schema, configurations: config)
    }()

    private func makeActivityRepository() -> GenericRepository<Activity> {
        GenericRepository(context: modelContainer.mainContext)
    }

    private func makeProfileRepository() -> GenericRepository<Profile> {
        GenericRepository(context: modelContainer.mainContext)
    }

    // MARK: - HomeInteractor (RF01 - visualizar grupos de atividade)

    // Cada par é (categoria atual, categoria esperada). O último caso testa a volta ao início.
    @Test(arguments: [
        (ActivityCategory.physical, ActivityCategory.cognitive),
        (.cognitive, .sensorial),
        (.sensorial, .social),
        (.social, .physical)
    ])
    func testingNextCategory(current: ActivityCategory, expected: ActivityCategory) {
        let presenterSpy = HomePresenterSpy()
        let interactor = HomeInteractor(repository: makeActivityRepository(), presenter: presenterSpy)

        interactor.nextCategory(current: current)
        
        #expect(presenterSpy.presentedCategory == expected)
    }
    
    // Mesmo esquema na direção contrária. O primeiro caso testa a volta ao final.
    @Test(arguments: [
        (ActivityCategory.physical, ActivityCategory.social),
        (.cognitive, .physical),
        (.sensorial, .cognitive),
        (.social, .sensorial)
    ])
    func testingPreviousCategory(current: ActivityCategory, expected: ActivityCategory) {
        let presenterSpy = HomePresenterSpy()
        let interactor = HomeInteractor(repository: makeActivityRepository(), presenter: presenterSpy)

        interactor.previousCategory(current: current)
        
        #expect(presenterSpy.presentedCategory == expected)
    }
    
    @Test func testingIfInteractorCatchesWeekCorrectly() throws {
        let presenterSpy = HomePresenterSpy()
        let interactor = HomeInteractor(repository: makeActivityRepository(), presenter: presenterSpy)
        
        interactor.getCurrentWeek()
        
        // #require falha o teste (sem crashar) se a semana não foi apresentada.
        let week = try #require(presenterSpy.week)
        #expect(week.count == 7)
        
        var calendar = Calendar.current
        calendar.firstWeekday = 1
        
        // A semana começa no domingo (weekday == 1).
        #expect(calendar.component(.weekday, from: week[0]) == 1)
        
        // Os dias são consecutivos.
        for index in 1..<week.count {
            let expected = calendar.date(byAdding: .day, value: 1, to: week[index - 1])
            #expect(week[index] == expected)
        }
    }

    // MARK: - ActivityInteractor (sorteio de desafios)
    
    private struct ActivitySUT {
        let interactor: ActivityInteractor
        let presenter: ActivityPresenterSpy
        let foundation: FoundationWorkerMock
        let haptics: HapticsWorkerMock
        let motion: CoreMotionWorkerMock
        let timer: TimerWorkerMock
        let liveActivity: WidgetWorkerMock
        let share: ShareWorkerMock
        let repository: GenericRepository<Activity>
    }
    
    private func makeActivitySUT() -> ActivitySUT {
        let presenter = ActivityPresenterSpy()
        let foundation = FoundationWorkerMock()
        let haptics = HapticsWorkerMock()
        let motion = CoreMotionWorkerMock()
        let timer = TimerWorkerMock()
        let liveActivity = WidgetWorkerMock()
        let share = ShareWorkerMock()
        let repository = makeActivityRepository()
        let interactor = ActivityInteractor(
            presenter: presenter,
            activityRepository: repository,
            hapticWorker: haptics,
            coreMotionWorker: motion,
            foundationWorker: foundation,
            camera: CameraWorkerMock(),
            share: share,
            timer: timer,
            liveActivity: liveActivity,
            currentCategory: .physical
        )
        return ActivitySUT(interactor: interactor, presenter: presenter, foundation: foundation,
                           haptics: haptics, motion: motion, timer: timer, liveActivity: liveActivity,
                           share: share, repository: repository)
        }
    
    /// O sorteio roda dentro de um `Task`; espera até a condição valer (ou 2s).
    private func wait(until condition: () -> Bool) async {
        for _ in 0..<200 where !condition() {
            try? await Task.sleep(for: .milliseconds(10))
        }
    }
    
    @Test func testingRerollPresentsSearchingThenChallenge() async {
        let sut = makeActivitySUT()
        
        sut.interactor.reroll(for: .cognitive)
        await wait { sut.presenter.events.count >= 2 }
        
        #expect(sut.presenter.events == [.searching, .challenge(title: "título")])
        #expect(sut.foundation.generateCalls.first?.category == .cognitive)
        #expect(sut.interactor.isRaffling == false)
    }
    
    @Test func testingRaffleFailureStatePresentsSearchFailed() async {
        let sut = makeActivitySUT()
        sut.foundation.stateAfterGenerate = .failed("sem modelo")
        
        sut.interactor.reroll(for: .physical)
        await wait { sut.presenter.events.count >= 2 }
        
        #expect(sut.presenter.events == [.searching, .searchFailed])
        #expect(sut.interactor.isRaffling == false)
    }
    
    @Test func testingRaffleWithoutFinishedStatePresentsSearchFailed() async {
        let sut = makeActivitySUT()
        sut.foundation.stateAfterGenerate = .idle
        
        sut.interactor.reroll(for: .social)
        await wait { sut.presenter.events.count >= 2 }
        
        #expect(sut.presenter.events == [.searching, .searchFailed])
    }
    
    @Test func testingRafflePassesOnlyArchivedActivitiesToWorker() async throws {
        let sut = makeActivitySUT()
        let archived = Activity(category: .sensorial, result: nil, name: "Arquivada", description: "-", archived: true)
        let notArchived = Activity(category: .sensorial, result: nil, name: "Normal", description: "-", archived: false)
        try sut.repository.add(archived)
        try sut.repository.add(notArchived)
        
        sut.interactor.reroll(for: .sensorial)
        await wait { sut.presenter.events.count >= 2 }
        
        let passed = try #require(sut.foundation.generateCalls.first).archived
        #expect(passed.map(\.name) == ["Arquivada"])
    }
    
    // MARK: ActivityInteractor (prepare / arquivar)
    
    @Test func testingPrepareWarmsUpModelWhenAvailable() {
        let sut = makeActivitySUT()
        
        sut.interactor.prepare(for: .physical)
        
        #expect(sut.foundation.prewarmedCategories == [.physical])
    }
    
    @Test func testingPrepareDoesNothingWhenModelUnavailable() {
        let sut = makeActivitySUT()
        sut.foundation.availability = .unavailable(.deviceNotEligible)
        
        sut.interactor.prepare(for: .physical)
        
        #expect(sut.foundation.prewarmedCategories.isEmpty)
    }
    
    @Test func testingArchiveChallengeSavesArchivedActivityAndPrewarms() throws {
        let sut = makeActivitySUT()
        
        sut.interactor.archiveActivity(title: "Cardio sem fones", description: "Faça cardio", in: .physical)
        
        let saved = try sut.repository.getAll()
        #expect(saved.count == 1)
        #expect(saved.first?.name == "Cardio sem fones")
        #expect(saved.first?.activityDescription == "Faça cardio")
        #expect(saved.first?.category == .physical)
        #expect(saved.first?.archived == true)
        #expect(sut.foundation.prewarmedCategories == [.physical])
    }
    
    // MARK: ActivityInteractor (detecção do chacoalhar)
    
    @Test func testingDetectMotionStartsHapticsAndMonitoring() {
        let sut = makeActivitySUT()
        
        sut.interactor.detectMotion(for: .physical)
        defer { sut.interactor.finishDetection() }
        
        #expect(sut.haptics.prepareCount == 1)
        #expect(sut.motion.startCount == 1)
    }
    
    @Test func testingLightMotionDoesNotStartHaptic() {
        let sut = makeActivitySUT()
        sut.interactor.detectMotion(for: .physical)
        defer { sut.interactor.finishDetection() }
        
        // Abaixo do motionFeedbackThreshold (0.3).
        sut.motion.onMotionUpdate?(0.1)
        
        #expect(sut.haptics.startLoopCount == 0)
        #expect(sut.haptics.intensities.isEmpty)
    }
    
    @Test func testingMotionIntensityIsNormalizedAndCapped() {
        let sut = makeActivitySUT()
        sut.interactor.detectMotion(for: .physical)
        defer { sut.interactor.finishDetection() }
        
        sut.motion.onMotionUpdate?(1.25)   // metade do threshold (2.5)
        sut.motion.onMotionUpdate?(10)     // muito acima: limitado a 1
        
        #expect(sut.haptics.startLoopCount == 2)
        #expect(sut.haptics.intensities == [0.5, 1.0])
    }
    
    @Test func testingStrongShakeThenStopTriggersRaffle() async {
        let sut = makeActivitySUT()
        sut.interactor.detectMotion(for: .cognitive)
        defer { sut.interactor.finishDetection() }
        
        sut.motion.onMotionUpdate?(5)             // cruza o shakeThreshold
        sut.haptics.onShakeSessionEnded?()        // pessoa parou de sacudir
        await wait { sut.presenter.events.count >= 2 }
        
        #expect(sut.presenter.events == [.searching, .challenge(title: "título")])
        #expect(sut.foundation.generateCalls.first?.category == .cognitive)
    }
    
    @Test func testingWeakShakeThenStopDoesNotRaffle() async {
        let sut = makeActivitySUT()
        sut.interactor.detectMotion(for: .cognitive)
        defer { sut.interactor.finishDetection() }
        
        sut.motion.onMotionUpdate?(1)             // vibra, mas não cruza o shakeThreshold
        sut.haptics.onShakeSessionEnded?()
        try? await Task.sleep(for: .milliseconds(100))
        
        #expect(sut.presenter.events.isEmpty)
        #expect(sut.foundation.generateCalls.isEmpty)
    }
    
    @Test func testingShakeSessionRafflesOnlyOncePerShake() async {
        let sut = makeActivitySUT()
        sut.interactor.detectMotion(for: .social)
        defer { sut.interactor.finishDetection() }
        
        sut.motion.onMotionUpdate?(5)
        sut.haptics.onShakeSessionEnded?()
        sut.haptics.onShakeSessionEnded?()        // a flag é zerada após o primeiro sorteio
        await wait { sut.presenter.events.count >= 2 }
        try? await Task.sleep(for: .milliseconds(100))
        
        #expect(sut.foundation.generateCalls.count == 1)
    }
    
    @Test func testingFinishDetectionStopsMotionAndHaptics() {
        let sut = makeActivitySUT()
        sut.interactor.detectMotion(for: .physical)
        
        sut.interactor.finishDetection()
        
        #expect(sut.motion.stopCount == 1)
        #expect(sut.haptics.stopLoopCount == 1)
        #expect(sut.interactor.shakeIdleTimer == nil)
    }
    
    // MARK: ActivityInteractor (cronômetro)

    @Test func testingStartTimerStoresStartDateAndListensToTicks() async {
        let sut = makeActivitySUT()

        sut.interactor.startTimer()
        defer { sut.interactor.cancelTimer() }
        await wait { sut.timer.ticksCallCount == 1 }

        #expect(sut.interactor.timerStartDate != nil)
        #expect(sut.timer.ticksCallCount == 1)
    }

    @Test func testingEachTickPresentsElapsedTime() async {
        let sut = makeActivitySUT()
        sut.interactor.startTimer()
        defer { sut.interactor.cancelTimer() }
        await wait { sut.timer.ticksCallCount == 1 }

        sut.timer.emitTick()
        sut.timer.emitTick()
        await wait { sut.presenter.presentedTimes.count >= 2 }

        #expect(sut.presenter.presentedTimes.count == 2)
        #expect(sut.presenter.presentedTimes.allSatisfy { $0 >= 0 })
    }

    // O tempo vem da data de início, não de um contador: 90s atrás tem que dar ~90s.
    @Test func testingCurrentElapsedIsCalculatedFromStartDate() {
        let sut = makeActivitySUT()
        sut.interactor.timerStartDate = Date().addingTimeInterval(-90)

        let elapsed = sut.interactor.currentElapsed()

        #expect(elapsed >= 90)
        #expect(elapsed < 91)
    }

    @Test func testingCurrentElapsedIsZeroWhenTimerIsNotRunning() {
        let sut = makeActivitySUT()

        #expect(sut.interactor.currentElapsed() == 0)
    }

    @Test func testingStopTimerFixesFinalElapsedTimeAndClearsStartDate() {
        let sut = makeActivitySUT()
        sut.interactor.timerStartDate = Date().addingTimeInterval(-30)

        sut.interactor.stopTimer()

        #expect(sut.interactor.timerElapsed >= 30)
        #expect(sut.interactor.timerElapsed < 31)
        #expect(sut.interactor.timerStartDate == nil)
    }

    @Test func testingStopTimerStopsListeningToTicks() async {
        let sut = makeActivitySUT()
        sut.interactor.startTimer()
        await wait { sut.timer.ticksCallCount == 1 }

        sut.interactor.stopTimer()
        await wait { sut.timer.terminationCount == 1 }
        let updatesBefore = sut.presenter.presentedTimes.count
        sut.timer.emitTick()
        try? await Task.sleep(for: .milliseconds(100))

        #expect(sut.timer.terminationCount == 1)
        #expect(sut.presenter.presentedTimes.count == updatesBefore)
    }

    @Test func testingCancelTimerDiscardsTimeAndPresentsZero() {
        let sut = makeActivitySUT()
        sut.interactor.timerStartDate = Date().addingTimeInterval(-30)
        sut.interactor.timerElapsed = 45

        sut.interactor.cancelTimer()

        #expect(sut.interactor.timerElapsed == 0)
        #expect(sut.interactor.timerStartDate == nil)
        #expect(sut.interactor.timerTask == nil)
        #expect(sut.presenter.presentedTimes == [0])
    }

    @Test func testingCancelTimerStopsListeningToTicks() async {
        let sut = makeActivitySUT()
        sut.interactor.startTimer()
        await wait { sut.timer.ticksCallCount == 1 }

        sut.interactor.cancelTimer()
        await wait { sut.timer.terminationCount == 1 }
        let updatesBefore = sut.presenter.presentedTimes.count
        sut.timer.emitTick()
        try? await Task.sleep(for: .milliseconds(100))

        #expect(sut.timer.terminationCount == 1)
        #expect(sut.presenter.presentedTimes.count == updatesBefore)
    }

    // Começar duas vezes não pode deixar dois "ouvintes": o primeiro é cancelado.
    @Test func testingStartingTimerTwiceKeepsOnlyOneListener() async {
        let sut = makeActivitySUT()
        sut.interactor.startTimer()
        await wait { sut.timer.ticksCallCount == 1 }

        sut.interactor.startTimer()
        defer { sut.interactor.cancelTimer() }
        await wait { sut.timer.ticksCallCount == 2 && sut.timer.terminationCount == 1 }

        sut.timer.emitTick()
        await wait { !sut.presenter.presentedTimes.isEmpty }
        try? await Task.sleep(for: .milliseconds(100))

        #expect(sut.timer.terminationCount == 1)
        #expect(sut.presenter.presentedTimes.count == 1)
    }

    @Test func testingStartActivityStartsTimerAndGoesToInProgress() async {
        let sut = makeActivitySUT()

        sut.interactor.startActivity()
        defer { sut.interactor.cancelTimer() }
        await wait { sut.timer.ticksCallCount == 1 }

        #expect(sut.interactor.timerStartDate != nil)
        #expect(sut.presenter.inProgressCount == 1)
    }

    @Test func testingCompleteActivityStopsTimerAndGoesToMood() {
        let sut = makeActivitySUT()
        sut.interactor.timerStartDate = Date().addingTimeInterval(-10)

        sut.interactor.completeActivity()

        #expect(sut.interactor.timerStartDate == nil)
        #expect(sut.interactor.timerElapsed >= 10)
        #expect(sut.presenter.moodCount == 1)
    }

    // Sair do fluxo no meio (ou cancelar) descarta o tempo e não deixa o cronômetro rodando.
    @Test func testingFinishActivityFlowCancelsTimerAndFinishesFlow() {
        let sut = makeActivitySUT()
        sut.interactor.timerStartDate = Date().addingTimeInterval(-10)
        sut.interactor.timerElapsed = 10

        sut.interactor.finishActivityFlow()

        #expect(sut.interactor.timerStartDate == nil)
        #expect(sut.interactor.timerElapsed == 0)
        #expect(sut.presenter.flowFinishedCount == 1)
    }
    
    
    // MARK: - ActivityInteractor (humor)

    @Test func testingNextHumorWrapsFromLastToFirst() {
        let sut = makeActivitySUT()
        sut.interactor.selectedHumor = .chill   // último da roleta

        sut.interactor.nextHumor()

        #expect(sut.interactor.selectedHumor == .frustrated)
        #expect(sut.presenter.presentedHumors == [.frustrated])
    }

    @Test func testingPreviousHumorWrapsFromFirstToLast() {
        let sut = makeActivitySUT()
        sut.interactor.selectedHumor = .frustrated   // primeiro da roleta

        sut.interactor.previousHumor()

        #expect(sut.interactor.selectedHumor == .chill)
        #expect(sut.presenter.presentedHumors == [.chill])
    }

    // MARK: - ActivityInteractor (compartilhamento)

    @Test func testingShareStoryWithoutImagePresentsError() {
        let sut = makeActivitySUT()

        sut.interactor.shareStory(nil)

        #expect(sut.presenter.presentedErrors.first as? ShareError == .renderFailed)
        #expect(sut.presenter.shareSheetURL == nil)
    }

    @Test func testingShareStoryOpensShareSheetWithFile() {
        let sut = makeActivitySUT()

        sut.interactor.shareStory(UIImage())

        #expect(sut.share.receivedImage != nil)
        #expect(sut.presenter.shareSheetURL == sut.share.url)
    }

    @Test func testingShareStoryWorkerFailurePresentsError() {
        let sut = makeActivitySUT()
        sut.share.errorToThrow = ShareError.encodingFailed

        sut.interactor.shareStory(UIImage())

        #expect(sut.presenter.presentedErrors.first as? ShareError == .encodingFailed)
        #expect(sut.presenter.shareSheetURL == nil)
    }

    // MARK: ActivityInteractor (Live Activity / Dynamic Island)

    // A ilha precisa começar no MESMO instante do cronômetro do app, senão os dois mostram tempos diferentes.
    @Test func testingStartTimerStartsLiveActivityWithSameStartDate() async {
        let sut = makeActivitySUT()

        sut.interactor.startTimer()
        defer { sut.interactor.cancelTimer() }
        await wait { sut.liveActivity.startCalls.count == 1 }

        #expect(sut.liveActivity.startCalls.count == 1)
        #expect(sut.liveActivity.startCalls.first?.startDate == sut.interactor.timerStartDate)
    }

    // O grupo da atividade (escolhido na Home) é o nome que aparece na ilha (o `.text` da categoria).
    @Test func testingStartTimerSendsCategoryNameToLiveActivity() async {
        let sut = makeActivitySUT()

        sut.interactor.startTimer()
        defer { sut.interactor.cancelTimer() }
        await wait { sut.liveActivity.startCalls.count == 1 }

        #expect(sut.liveActivity.startCalls.first?.name == ActivityCategory.physical.text)
    }

    @Test func testingStopTimerSendsFinalTimeToLiveActivity() async throws {
        let sut = makeActivitySUT()
        sut.interactor.timerStartDate = Date().addingTimeInterval(-30)

        sut.interactor.stopTimer()
        await wait { sut.liveActivity.stopElapsed.count == 1 }

        let elapsed = try #require(sut.liveActivity.stopElapsed.first)
        #expect(elapsed >= 30)
        #expect(elapsed < 31)
        #expect(sut.liveActivity.cancelCount == 0)
    }

    @Test func testingCancelTimerCancelsLiveActivityWithoutSendingTime() async {
        let sut = makeActivitySUT()
        sut.interactor.timerStartDate = Date().addingTimeInterval(-30)

        sut.interactor.cancelTimer()
        await wait { sut.liveActivity.cancelCount == 1 }

        #expect(sut.liveActivity.cancelCount == 1)
        #expect(sut.liveActivity.stopElapsed.isEmpty)
    }

    @Test func testingStartActivityStartsLiveActivity() async {
        let sut = makeActivitySUT()

        sut.interactor.startActivity()
        defer { sut.interactor.cancelTimer() }
        await wait { sut.liveActivity.startCalls.count == 1 }

        #expect(sut.liveActivity.startCalls.count == 1)
    }

    @Test func testingCompleteActivityStopsLiveActivityInsteadOfCancelling() async {
        let sut = makeActivitySUT()
        sut.interactor.timerStartDate = Date().addingTimeInterval(-10)

        sut.interactor.completeActivity()
        await wait { sut.liveActivity.stopElapsed.count == 1 }

        #expect(sut.liveActivity.stopElapsed.count == 1)
        #expect(sut.liveActivity.cancelCount == 0)
    }

    // Sair do fluxo no meio não pode deixar a ilha "órfã" na tela.
    @Test func testingFinishActivityFlowCancelsLiveActivity() async {
        let sut = makeActivitySUT()
        sut.interactor.timerStartDate = Date().addingTimeInterval(-10)

        sut.interactor.finishActivityFlow()
        await wait { sut.liveActivity.cancelCount == 1 }

        #expect(sut.liveActivity.cancelCount == 1)
        #expect(sut.liveActivity.stopElapsed.isEmpty)
    }

//    // MARK: - ProfileInteractor (RF24/onboarding - perfil padrão)
//
//    @Test func testingFetchProfileCreatesDefaultWhenMissing() async throws {
//        let repository = makeProfileRepository()
//        let presenterSpy = ProfilePresenterSpy()
//        let interactor = ProfileInteractor(repository: repository, presenter: presenterSpy)
//
//        interactor.fetchProfile()
//
//        #expect(presenterSpy.presentedProfile != nil)
//        #expect(presenterSpy.presentedProfile?.streak == 0)
//        #expect(repository.fetchAll().count == 1)
//    }
//
//    // MARK: - ProfileInteractor (RF27 - definir tema)
//
//    @Test func testingUpdateThemePersistsAndPresentsNewTheme() async throws {
//        let repository = makeProfileRepository()
//        let presenterSpy = ProfilePresenterSpy()
//        let interactor = ProfileInteractor(repository: repository, presenter: presenterSpy)
//        interactor.fetchProfile()
//
//        interactor.updateTheme(.themeThree)
//
//        #expect(presenterSpy.presentedProfile?.theme == .themeThree)
//        #expect(repository.fetchAll().first?.theme == .themeThree)
//    }
//
//    // MARK: - ProfileInteractor (RF25/RF26 - localização e notificações)
//
//    @Test func testingUpdateLocalizableAndNotificationsTogglesFlags() async throws {
//        let repository = makeProfileRepository()
//        let presenterSpy = ProfilePresenterSpy()
//        let interactor = ProfileInteractor(repository: repository, presenter: presenterSpy)
//        interactor.fetchProfile()
//
//        interactor.updateLocalizable(true)
//        interactor.updateNotifications(true)
//
//        #expect(presenterSpy.presentedProfile?.localizable == true)
//        #expect(presenterSpy.presentedProfile?.notifications == true)
//    }
}
