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
    private(set) var photoCount = 0
    /// Textos do desafio que o Interactor devolveu à Store ao restaurar o fluxo, em ordem.
    private(set) var restoredChallenges: [(title: String, subtitle: String, description: String)] = []
    private(set) var summaryCount = 0
    /// Conquistas que o Interactor mandou para o summary, em ordem.
    private(set) var presentedAchievements: [Achievement] = []
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
    func presentPhoto() { photoCount += 1 }
    func presentRestoredChallenge(title: String, subtitle: String, description: String) {
        restoredChallenges.append((title, subtitle, description))
    }
    func presentCamera() {}
    func presentCameraClosed() {}
    func presentPermissionDenied() {}
    func presentCaptured(_ data: Data) {}
    func presentFlash(isOn: Bool) {}
    func presentAlertsDismissed() {}
    func presentSummary(achievement: Achievement) {
        summaryCount += 1
        presentedAchievements.append(achievement)
    }
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

    var achievementToReturn = Achievement(title: "título da conquista", description: "descrição da conquista")
    private(set) var achievementCalls: [(activity: Activity, elapsed: TimeInterval)] = []

    func generateAchievement(for activity: Activity, elapsed: TimeInterval) async -> Achievement {
        achievementCalls.append((activity, elapsed))
        return achievementToReturn
    }
}

final class HapticsWorkerMock: HapticsWorkerProtocol {
    var onShakeSessionEnded: (() -> Void)?
    
    private(set) var prepareCount = 0
    private(set) var startLoopCount = 0
    private(set) var intensities: [Double] = []
    private(set) var stopLoopCount = 0
    private(set) var selectionTickCount = 0
    
    func prepareHaptics() { prepareCount += 1 }
    func startShakeLoop() { startLoopCount += 1 }
    func updateShakeIntensity(_ magnitude: Double) { intensities.append(magnitude) }
    func stopShakeLoopIfIdle(timeout: TimeInterval) {}
    func stopShakeLoop() { stopLoopCount += 1 }
    func playSelectionTick() { selectionTickCount += 1 }
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

/// Anota o que o Interactor de Feelings entregou ao Presenter, uma entrada por chamada.
final class FeelingsPresenterSpy: FeelingsPresenterProtocol {
    private(set) var presentedActivities: [[Activity]] = []
    private(set) var selectedActivities: [Activity] = []
    private(set) var cameraPresentedCount = 0
    private(set) var cameraClosedCount = 0
    private(set) var permissionDeniedCount = 0
    private(set) var photoUpdates: [Data] = []
    private(set) var flashStates: [Bool] = []
    private(set) var presentedErrors: [Error] = []
    private(set) var alertsDismissedCount = 0
    private(set) var storyActivities: [Activity] = []
    private(set) var shareSheetURL: URL?
    private(set) var shareFinished: Bool?
    private(set) var detailVisibilityChanges: [Bool] = []

    func presentFeelingsLoaded(activities: [Activity]) {
        presentedActivities.append(activities)
    }

    func presentSelectedActivity(activity: Activity) { selectedActivities.append(activity) }
    func presentCamera() { cameraPresentedCount += 1 }
    func presentCameraClosed() { cameraClosedCount += 1 }
    func presentPermissionDenied() { permissionDeniedCount += 1 }
    func presentPhotoUpdated(_ data: Data) { photoUpdates.append(data) }
    func presentFlash(isOn: Bool) { flashStates.append(isOn) }
    func presentError(_ error: Error) { presentedErrors.append(error) }
    func presentAlertsDismissed() { alertsDismissedCount += 1 }
    func presentDetailVisibility(isVisible: Bool) { detailVisibilityChanges.append(isVisible) }
    func presentStory(for activity: Activity) { storyActivities.append(activity) }
    func presentShareSheet(fileURL: URL) { shareSheetURL = fileURL }
    func presentShareFinished(completed: Bool) { shareFinished = completed }
}

/// Câmera falsa configurável: o teste escolhe a permissão e o resultado de cada operação.
/// Tudo responde na hora (sem fila), então o teste não precisa esperar.
final class ConfigurableCameraWorkerMock: CameraWorkerProtocol {
    var permission: CameraPermission = .authorized
    var permissionGranted = true
    var startResult: Result<Void, Error> = .success(())
    var switchResult: Result<Void, Error> = .success(())
    var captureResult: Result<Data, Error> = .success(Data([1, 2, 3]))
    private(set) var requestPermissionCount = 0
    private(set) var startCount = 0
    private(set) var stopCount = 0
    private(set) var switchCount = 0
    private(set) var captureFlashValues: [Bool] = []

    func permissionStatus() -> CameraPermission { permission }
    func requestPermission(completion: @escaping (Bool) -> Void) {
        requestPermissionCount += 1
        completion(permissionGranted)
    }
    func startSession(completion: @escaping (Result<Void, Error>) -> Void) {
        startCount += 1
        completion(startResult)
    }
    func stopSession() { stopCount += 1 }
    func switchCamera(completion: @escaping (Result<Void, Error>) -> Void) {
        switchCount += 1
        completion(switchResult)
    }
    func capturePhoto(flash: Bool, completion: @escaping (Result<Data, Error>) -> Void) {
        captureFlashValues.append(flash)
        completion(captureResult)
    }
}

/// Anota o que o Interactor de Desafios entregou ao Presenter, uma entrada por chamada.
/// `@MainActor` porque o `ChallengesPresenterProtocol` também é.
@MainActor
final class ChallengesPresenterSpy: ChallengesPresenterProtocol {

    /// Uma chamada de `presentChallenges`, com tudo que o Interactor mandou.
    struct ChallengesCall {
        let activities: [Activity]
        let selectedCategory: ActivityCategory?
        let hasCompletedChallenges: Bool
    }

    private(set) var challengesCalls: [ChallengesCall] = []
    private(set) var archivedCalls: [[Activity]] = []
    private(set) var archivedSheetStates: [Bool] = []
    private(set) var summaries: [Activity?] = []
    private(set) var shareSheetURL: URL?
    private(set) var shareFinished: Bool?
    private(set) var errors: [String?] = []
    
    // Câmera (tirar outra foto no resumo)
    private(set) var cameraStates: [Bool] = []
    private(set) var cameraClosedCount = 0
    private(set) var permissionDeniedCount = 0
    private(set) var flashStates: [Bool] = []
    private(set) var cameraErrors: [Error] = []

    func presentCamera(isPresented: Bool) { cameraStates.append(isPresented) }
    func presentCameraClosed() { cameraClosedCount += 1 }
    func presentPermissionDenied() { permissionDeniedCount += 1 }
    func presentFlash(isOn: Bool) { flashStates.append(isOn) }
    func presentCameraError(_ error: Error) { cameraErrors.append(error) }

    /// Atalho para os nomes da última lista apresentada (ordenados, porque o banco não garante ordem).
    var lastChallengeNames: [String]? { challengesCalls.last?.activities.map(\.name).sorted() }
    var lastArchivedNames: [String]? { archivedCalls.last?.map(\.name).sorted() }

    func presentChallenges(_ activities: [Activity], selectedCategory: ActivityCategory?, hasCompletedChallenges: Bool) {
        challengesCalls.append(ChallengesCall(activities: activities, selectedCategory: selectedCategory,
                                              hasCompletedChallenges: hasCompletedChallenges))
    }
    func presentArchivedChallenges(_ activities: [Activity]) { archivedCalls.append(activities) }
    func presentArchivedSheet(isPresented: Bool) { archivedSheetStates.append(isPresented) }
    func presentSummary(_ activity: Activity?) { summaries.append(activity) }
    func presentShareSheet(fileURL: URL) { shareSheetURL = fileURL }
    func presentShareFinished(completed: Bool) { shareFinished = completed }
    func presentError(_ message: String?) { errors.append(message) }
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
    
    // MARK: ActivityInteractor (restaurar o fluxo depois dos Ajustes)

    /// `UserDefaults` só deste teste, para não mexer no do app nem em outros testes.
    private func makeIsolatedDefaults() -> UserDefaults {
        let name = "InteractorTests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: name)!
        defaults.removePersistentDomain(forName: name)
        return defaults
    }

    /// Deixa o Interactor no step `.photo`: `Activity` e `ActivityResult` já estão no banco.
    @discardableResult
    private func prepareAtPhotoStep(_ sut: ActivitySUT, humor: Humor = .calm) throws -> Activity {
        let result = ActivityResult(achievementTitle: "mestre offline",
                                    achievementDescription: "você ficou 5 minutos sem celular",
                                    time: 300,
                                    humor: humor)
        let activity = Activity(category: .physical, result: result, name: "título", description: "sub", archived: false)
        try sut.repository.add(activity)
        sut.interactor.currentActivity = activity
        sut.interactor.result = result
        return activity
    }

    @Test func testingCacheDataThenRestoreDataRestoresInteractorStateAndPresents() throws {
        let defaults = makeIsolatedDefaults()
        let saved = makeActivitySUT()
        saved.interactor.defaults = defaults
        let activity = try prepareAtPhotoStep(saved, humor: .frustrated)
        saved.interactor.cacheData(title: "título", subtitle: "sub", description: "descrição")

        // Um Interactor novo, como depois de o iOS encerrar o app.
        let restored = makeActivitySUT()
        restored.interactor.defaults = defaults
        restored.interactor.restoreData()

        #expect(restored.interactor.currentActivity === activity)
        #expect(restored.interactor.result === activity.result)
        #expect(restored.interactor.selectedHumor == .frustrated)
        // A conquista não estava na memória ao salvar: vem do que já estava gravado no `result`.
        #expect(restored.interactor.achievement?.title == "mestre offline")
        #expect(restored.interactor.achievement?.description == "você ficou 5 minutos sem celular")
        #expect(restored.presenter.presentedHumors == [.frustrated])
        #expect(restored.presenter.restoredChallenges.count == 1)
        #expect(restored.presenter.restoredChallenges.first?.title == "título")
        #expect(restored.presenter.restoredChallenges.first?.subtitle == "sub")
        #expect(restored.presenter.restoredChallenges.first?.description == "descrição")
        #expect(restored.presenter.photoCount == 1)
    }

    @Test func testingContinueFromPhotoAfterRestoreOpensSummaryWithTheStoredAchievement() throws {
        let defaults = makeIsolatedDefaults()
        let saved = makeActivitySUT()
        saved.interactor.defaults = defaults
        try prepareAtPhotoStep(saved)
        saved.interactor.cacheData(title: "t", subtitle: "s", description: "d")

        let restored = makeActivitySUT()
        restored.interactor.defaults = defaults
        restored.interactor.restoreData()
        restored.interactor.continueFromPhoto()

        #expect(restored.presenter.summaryCount == 1)
        #expect(restored.presenter.presentedAchievements.first?.title == "mestre offline")
    }

    @Test func testingCacheDataPrefersTheAchievementInMemory() throws {
        let defaults = makeIsolatedDefaults()
        let saved = makeActivitySUT()
        saved.interactor.defaults = defaults
        try prepareAtPhotoStep(saved)
        saved.interactor.achievement = Achievement(title: "da memória", description: "descrição da memória")
        saved.interactor.cacheData(title: "t", subtitle: "s", description: "d")

        let restored = makeActivitySUT()
        restored.interactor.defaults = defaults
        restored.interactor.restoreData()

        #expect(restored.interactor.achievement?.title == "da memória")
        #expect(restored.interactor.achievement?.description == "descrição da memória")
    }

    @Test func testingCacheDataWithoutActivitySavesNothing() {
        let defaults = makeIsolatedDefaults()
        let sut = makeActivitySUT()
        sut.interactor.defaults = defaults

        sut.interactor.cacheData(title: "t", subtitle: "s", description: "d")

        #expect(defaults.data(forKey: TemporaryData.key) == nil)
    }

    @Test func testingRestoreDataWithoutSnapshotDoesNothing() {
        let sut = makeActivitySUT()
        sut.interactor.defaults = makeIsolatedDefaults()

        sut.interactor.restoreData()

        #expect(sut.interactor.currentActivity == nil)
        #expect(sut.interactor.achievement == nil)
        #expect(sut.presenter.presentedHumors.isEmpty)
        #expect(sut.presenter.restoredChallenges.isEmpty)
        #expect(sut.presenter.photoCount == 0)
    }

    @Test func testingRestoreDataConsumesTheSnapshot() throws {
        let defaults = makeIsolatedDefaults()
        let saved = makeActivitySUT()
        saved.interactor.defaults = defaults
        try prepareAtPhotoStep(saved)
        saved.interactor.cacheData(title: "t", subtitle: "s", description: "d")

        let first = makeActivitySUT()
        first.interactor.defaults = defaults
        first.interactor.restoreData()
        let second = makeActivitySUT()
        second.interactor.defaults = defaults
        second.interactor.restoreData()

        #expect(defaults.data(forKey: TemporaryData.key) == nil)
        #expect(first.presenter.photoCount == 1)
        #expect(second.presenter.photoCount == 0)
    }

    @Test func testingRestoreDataIgnoresAnExpiredSnapshot() throws {
        let defaults = makeIsolatedDefaults()
        let saved = makeActivitySUT()
        saved.interactor.defaults = defaults
        let activity = try prepareAtPhotoStep(saved)
        let expired = TemporaryData(step: .photo,
                                    category: .physical,
                                    activityID: activity.activityID,
                                    resultID: try #require(activity.result).resultID,
                                    title: "t",
                                    subtitle: "s",
                                    description: "d",
                                    achievementTitle: "a",
                                    achievementDescription: "b",
                                    savedAt: Date().addingTimeInterval(-2 * 60 * 60))
        defaults.set(try JSONEncoder().encode(expired), forKey: TemporaryData.key)

        let restored = makeActivitySUT()
        restored.interactor.defaults = defaults
        restored.interactor.restoreData()

        #expect(restored.interactor.currentActivity == nil)
        #expect(restored.presenter.photoCount == 0)
        // Mesmo expirado, o snapshot é apagado.
        #expect(defaults.data(forKey: TemporaryData.key) == nil)
    }

    @Test func testingRestoreDataIgnoresASnapshotWhoseActivityWasDeleted() throws {
        let defaults = makeIsolatedDefaults()
        let saved = makeActivitySUT()
        saved.interactor.defaults = defaults
        let activity = try prepareAtPhotoStep(saved)
        saved.interactor.cacheData(title: "t", subtitle: "s", description: "d")
        try saved.repository.delete(activity)

        let restored = makeActivitySUT()
        restored.interactor.defaults = defaults
        restored.interactor.restoreData()

        #expect(restored.interactor.currentActivity == nil)
        #expect(restored.presenter.restoredChallenges.isEmpty)
        #expect(restored.presenter.photoCount == 0)
    }

    @Test func testingLoadReturnsAValidSnapshotWithoutDeletingIt() throws {
        let defaults = makeIsolatedDefaults()
        let snapshot = TemporaryData(step: .photo, category: .social, activityID: UUID(), resultID: UUID(),
                                     title: "t", subtitle: "s", description: "d",
                                     achievementTitle: "a", achievementDescription: "b", savedAt: Date())
        defaults.set(try JSONEncoder().encode(snapshot), forKey: TemporaryData.key)

        let loaded = TemporaryData.load(from: defaults)

        #expect(loaded?.category == .social)
        #expect(loaded?.activityID == snapshot.activityID)
        #expect(loaded?.step == .photo)
        // A Home só espia: quem apaga é o `restoreData()`.
        #expect(defaults.data(forKey: TemporaryData.key) != nil)
    }

    @Test func testingLoadWithoutSnapshotReturnsNil() {
        #expect(TemporaryData.load(from: makeIsolatedDefaults()) == nil)
    }

    @Test func testingLoadIgnoresAnExpiredSnapshot() throws {
        let defaults = makeIsolatedDefaults()
        let expired = TemporaryData(step: .photo, category: .physical, activityID: UUID(), resultID: UUID(),
                                    title: "t", subtitle: "s", description: "d",
                                    achievementTitle: "a", achievementDescription: "b",
                                    savedAt: Date().addingTimeInterval(-TemporaryData.lifetime - 1))
        defaults.set(try JSONEncoder().encode(expired), forKey: TemporaryData.key)

        #expect(TemporaryData.load(from: defaults) == nil)
    }

    @Test func testingLoadIgnoresCorruptedData() {
        let defaults = makeIsolatedDefaults()
        defaults.set(Data("não é um json".utf8), forKey: TemporaryData.key)

        #expect(TemporaryData.load(from: defaults) == nil)
    }

    @Test func testingFinishActivityFlowDiscardsALeftoverSnapshot() throws {
        let defaults = makeIsolatedDefaults()
        let sut = makeActivitySUT()
        sut.interactor.defaults = defaults
        try prepareAtPhotoStep(sut)
        sut.interactor.cacheData(title: "t", subtitle: "s", description: "d")
        #expect(defaults.data(forKey: TemporaryData.key) != nil)

        sut.interactor.finishActivityFlow()

        #expect(defaults.data(forKey: TemporaryData.key) == nil)
        #expect(sut.presenter.flowFinishedCount == 1)
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

        completeActivity(on: sut)

        #expect(sut.interactor.timerStartDate == nil)
        #expect(sut.interactor.timerElapsed >= 10)
        #expect(sut.presenter.moodCount == 1)
    }

    // MARK: ActivityInteractor (persistência ao longo do fluxo)

    private func completeActivity(on sut: ActivitySUT,
                                  category: ActivityCategory = .physical,
                                  title: String = "Cardio sem fones",
                                  subTitle: String = "Faça cardio",
                                  description: String = "Porque faz bem") {
        sut.interactor.completeActivity(currentCategory: category, title: title,
                                        subTitle: subTitle, Description: description)
    }

    // Ao completar, a atividade já nasce no banco (não arquivada) e fica em `currentActivity`.
    @Test func testingCompleteActivitySavesNonArchivedActivityInRepository() throws {
        let sut = makeActivitySUT()

        completeActivity(on: sut, category: .social)

        let saved = try sut.repository.getAll()
        #expect(saved.count == 1)
        #expect(saved.first?.name == "Cardio sem fones")
        #expect(saved.first?.activityDescription == "Faça cardio")
        #expect(saved.first?.category == .social)
        #expect(saved.first?.archived == false)
        #expect(sut.interactor.currentActivity === saved.first)
    }

    @Test func testingSelectMoodUpdatesResultAndGoesToPhoto() {
        let sut = makeActivitySUT()
        completeActivity(on: sut)
        let result = ActivityResult(time: 10, humor: .veryPleasant)
        sut.interactor.result = result

        sut.interactor.selectMood(humor: .veryUnpleasant)

        #expect(result.humor == .veryUnpleasant)
        #expect(sut.interactor.currentActivity?.result === result)
        #expect(sut.presenter.photoCount == 1)
    }

    @Test func testingContinueFromPhotoStoresPhotoInResultAndGoesToSummary() {
        let sut = makeActivitySUT()
        completeActivity(on: sut)
        let result = ActivityResult(time: 10, humor: .veryPleasant)
        let photo = Data([0x01, 0x02])
        sut.interactor.result = result
        sut.interactor.selectedPhoto = photo
        sut.interactor.achievement = Achievement(title: "mestre offline", description: "você passou 1h offline")

        sut.interactor.continueFromPhoto()

        #expect(result.photo == photo)
        #expect(sut.interactor.currentActivity?.result === result)
        #expect(sut.presenter.summaryCount == 1)
    }

    @Test func testingContinueFromPhotoWithoutPhotoKeepsResultPhotoNil() {
        let sut = makeActivitySUT()
        completeActivity(on: sut)
        let result = ActivityResult(time: 10, humor: .veryPleasant)
        sut.interactor.result = result
        sut.interactor.achievement = Achievement(title: "mestre offline", description: "você passou 1h offline")

        sut.interactor.continueFromPhoto()

        #expect(result.photo == nil)
        #expect(sut.presenter.summaryCount == 1)
    }
    
    // Ao completar, o resultado já nasce com o tempo (sem humor nem foto),
    // para o tempo não se perder se o usuário sair na tela de humor.
    @Test func testingCompleteActivitySavesResultWithTimeAndNoHumor() throws {
        let sut = makeActivitySUT()
        sut.interactor.timerStartDate = Date().addingTimeInterval(-10)

        completeActivity(on: sut)

        let saved = try #require(sut.repository.getAll().first)
        let result = try #require(saved.result)
        #expect(result.time >= 10)
        #expect(result.humor == nil)
        #expect(result.photo == nil)
        #expect(sut.interactor.result === result)
    }

    // Sair na tela de humor mantém o tempo salvo (o `cancelTimer` só zera o valor em memória).
    @Test func testingFinishFlowAfterCompletingKeepsSavedTime() throws {
        let sut = makeActivitySUT()
        sut.interactor.timerStartDate = Date().addingTimeInterval(-10)
        completeActivity(on: sut)

        sut.interactor.finishActivityFlow()

        let saved = try #require(sut.repository.getAll().first)
        #expect((saved.result?.time ?? 0) >= 10)
    }

    // A conquista que o Interactor guardou é a que vai para o summary (e daí para a Store).
    @Test func testingContinueFromPhotoPresentsTheStoredAchievement() {
        let sut = makeActivitySUT()
        completeActivity(on: sut)
        sut.interactor.result = ActivityResult(time: 10, humor: .chill)
        sut.interactor.achievement = Achievement(title: "mestre offline", description: "você passou 1h offline")

        sut.interactor.continueFromPhoto()

        #expect(sut.presenter.presentedAchievements.first?.title == "mestre offline")
        #expect(sut.presenter.presentedAchievements.first?.description == "você passou 1h offline")
    }

    // MARK: ActivityInteractor (conquista)

    // A conquista nasce ao parar o cronômetro, a partir da atividade já salva e do tempo final.
    @Test func testingStopTimerGeneratesAchievementForCurrentActivity() async throws {
        let sut = makeActivitySUT()
        sut.interactor.timerStartDate = Date().addingTimeInterval(-30)

        completeActivity(on: sut, title: "Cardio sem fones")
        await sut.interactor.achievementTask?.value

        let call = try #require(sut.foundation.achievementCalls.first)
        #expect(sut.foundation.achievementCalls.count == 1)
        #expect(call.activity === sut.interactor.currentActivity)
        #expect(call.activity.name == "Cardio sem fones")
        #expect(call.elapsed >= 30)
        #expect(call.elapsed < 31)
        #expect(sut.interactor.achievement?.title == "título da conquista")
        #expect(sut.interactor.achievement?.description == "descrição da conquista")
    }

    // Sem atividade salva não há o que celebrar: nem chama o modelo.
    @Test func testingStopTimerWithoutCurrentActivityDoesNotGenerateAchievement() {
        let sut = makeActivitySUT()
        sut.interactor.timerStartDate = Date().addingTimeInterval(-30)

        sut.interactor.stopTimer()

        #expect(sut.interactor.achievementTask == nil)
        #expect(sut.interactor.achievement == nil)
        #expect(sut.foundation.achievementCalls.isEmpty)
    }

    // Humor escolhido ANTES da conquista chegar: o result já existe e recebe os textos depois.
    @Test func testingAchievementArrivingAfterResultIsWrittenInIt() async {
        let sut = makeActivitySUT()
        completeActivity(on: sut)
        let result = ActivityResult(time: 10, humor: .chill)
        sut.interactor.result = result

        await sut.interactor.achievementTask?.value

        #expect(result.achievementTitle == "título da conquista")
        #expect(result.achievementDescription == "descrição da conquista")
    }

    // Conquista pronta ANTES do humor: o result criado depois já nasce com os textos.
    @Test func testingResultCreatedAfterAchievementStartsWithItsTexts() async {
        let sut = makeActivitySUT()
        completeActivity(on: sut)
        await sut.interactor.achievementTask?.value

        let result = sut.interactor.makeResultIfNeeded()

        #expect(result.achievementTitle == "título da conquista")
        #expect(result.achievementDescription == "descrição da conquista")
    }

    @Test func testingResultCreatedBeforeAchievementStartsWithEmptyTexts() {
        let sut = makeActivitySUT()

        let result = sut.interactor.makeResultIfNeeded()

        #expect(result.achievementTitle.isEmpty)
        #expect(result.achievementDescription.isEmpty)
    }

    // Cancelar (ou sair do fluxo) antes de a conquista chegar não pode deixá-la vazar para o result.
    @Test func testingCancelTimerDiscardsAchievementStillBeingGenerated() async {
        let sut = makeActivitySUT()
        completeActivity(on: sut)
        let result = ActivityResult(time: 10, humor: .chill)
        sut.interactor.result = result

        sut.interactor.cancelTimer()
        try? await Task.sleep(for: .milliseconds(100))

        #expect(sut.interactor.achievementTask == nil)
        #expect(sut.interactor.achievement == nil)
        #expect(result.achievementTitle.isEmpty)
    }

    @Test func testingCancelTimerClearsAchievementAlreadyGenerated() async {
        let sut = makeActivitySUT()
        completeActivity(on: sut)
        await sut.interactor.achievementTask?.value

        sut.interactor.cancelTimer()

        #expect(sut.interactor.achievement == nil)
    }

    // Terminar o fluxo passa por `cancelTimer`: a conquista de uma atividade não vai para a próxima.
    @Test func testingFinishActivityFlowClearsAchievement() async {
        let sut = makeActivitySUT()
        completeActivity(on: sut)
        await sut.interactor.achievementTask?.value

        sut.interactor.finishActivityFlow()

        #expect(sut.interactor.achievement == nil)
        #expect(sut.interactor.achievementTask == nil)
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

    // Ao finalizar, o estado do fluxo é limpo, mas o que já foi salvo continua no banco.
    @Test func testingFinishActivityFlowClearsFlowStateAndKeepsSavedActivity() throws {
        let sut = makeActivitySUT()
        completeActivity(on: sut)
        sut.interactor.result = ActivityResult(time: 10, humor: .veryPleasant)

        sut.interactor.finishActivityFlow()

        #expect(sut.interactor.currentActivity == nil)
        #expect(sut.interactor.result == nil)
        #expect(try sut.repository.getAll().count == 1)
    }
    
    
    // MARK: - ActivityInteractor (humor)

    @Test func testingNextHumorWrapsFromLastToFirst() {
        let sut = makeActivitySUT()
        sut.interactor.selectedHumor = .veryPleasant   // último da roleta

        sut.interactor.nextHumor()

        #expect(sut.interactor.selectedHumor == .veryUnpleasant)
        #expect(sut.presenter.presentedHumors == [.veryUnpleasant])
    }

    @Test func testingPreviousHumorWrapsFromFirstToLast() {
        let sut = makeActivitySUT()
        sut.interactor.selectedHumor = .veryUnpleasant   // primeiro da roleta

        sut.interactor.previousHumor()

        #expect(sut.interactor.selectedHumor == .veryPleasant)
        #expect(sut.presenter.presentedHumors == [.veryPleasant])
    }
    
    @Test func testingEachHumorChangePlaysOneSelectionTick() {
        let sut = makeActivitySUT()
 
        sut.interactor.nextHumor()
        sut.interactor.nextHumor()
        sut.interactor.previousHumor()
 
        #expect(sut.haptics.selectionTickCount == 3)
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

        completeActivity(on: sut)
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
    
    // MARK: ActivityInteractor (seta de voltar)

    @Test func testingBackOnDrawFinishesFlow() async {
        let sut = makeActivitySUT()

        sut.interactor.didTapBack(on: .draw)
        await wait { sut.liveActivity.cancelCount == 1 }

        #expect(sut.presenter.flowFinishedCount == 1)
        #expect(sut.liveActivity.cancelCount == 1)
    }

    @Test func testingBackOnPhotoGoesToMood() {
        let sut = makeActivitySUT()

        sut.interactor.didTapBack(on: .photo)

        #expect(sut.presenter.moodCount == 1)
        #expect(sut.presenter.flowFinishedCount == 0)
    }

    @Test func testingBackOnSummaryGoesToPhoto() {
        let sut = makeActivitySUT()

        sut.interactor.didTapBack(on: .summary)

        #expect(sut.presenter.photoCount == 1)
        #expect(sut.presenter.flowFinishedCount == 0)
    }

    // Esses steps não usam a seta: a chamada não pode navegar nem encerrar o fluxo.
    @Test(arguments: [ActivityStep.challenge, .inProgress, .mood])
    func testingBackOnStepsWithoutBackActionDoesNothing(step: ActivityStep) {
        let sut = makeActivitySUT()

        sut.interactor.didTapBack(on: step)

        #expect(sut.presenter.moodCount == 0)
        #expect(sut.presenter.photoCount == 0)
        #expect(sut.presenter.flowFinishedCount == 0)
        #expect(sut.presenter.presentedTimes.isEmpty)
    }

    // MARK: - ChallengesInteractor (listagem)

    private struct ChallengesSUT {
        let interactor: ChallengesInteractor
        let presenter: ChallengesPresenterSpy
        let repository: GenericRepository<Activity>
        let share: ShareWorkerMock
        let camera: ConfigurableCameraWorkerMock
    }

    private func makeChallengesSUT() -> ChallengesSUT {
        let presenter = ChallengesPresenterSpy()
        let repository = makeActivityRepository()
        let share = ShareWorkerMock()
        let camera = ConfigurableCameraWorkerMock()
        let interactor = ChallengesInteractor(repository: repository, presenter: presenter, share: share, camera: camera)
        return ChallengesSUT(interactor: interactor, presenter: presenter, repository: repository, share: share, camera: camera)
    }

    /// Concluído = não arquivado e com `ActivityResult`. `humor == nil` cria sem resultado.
    @discardableResult
    private func addChallenge(_ name: String,
                              category: ActivityCategory = .physical,
                              humor: Humor? = .calm,
                              archived: Bool = false,
                              createdAt: Date = Date(),
                              in repository: GenericRepository<Activity>) throws -> Activity {
        let result = archived ? nil : ActivityResult(time: 10, humor: humor)
        let activity = Activity(category: category, result: result, createdAt: createdAt,
                                name: name, description: "-", archived: archived)
        try repository.add(activity)
        return activity
    }

    @Test func testingLoadChallengesWithEmptyDatabasePresentsEmptyLists() throws {
        let sut = makeChallengesSUT()

        sut.interactor.loadChallenges()

        let call = try #require(sut.presenter.challengesCalls.last)
        #expect(call.activities.isEmpty)
        #expect(call.hasCompletedChallenges == false)
        #expect(call.selectedCategory == nil)
        #expect(sut.presenter.archivedCalls.last?.isEmpty == true)
        #expect(sut.presenter.errors.isEmpty)
    }

    // Concluídos (com ou sem humor) e arquivados vão para listas diferentes.
    @Test func testingLoadChallengesSplitsCompletedAndArchived() throws {
        let sut = makeChallengesSUT()
        try addChallenge("Caminhada", in: sut.repository)
        try addChallenge("Leitura", category: .cognitive, humor: .chill, in: sut.repository)
        try addChallenge("Sem humor", humor: nil, in: sut.repository)
        try addChallenge("Arquivada", archived: true, in: sut.repository)

        sut.interactor.loadChallenges()

        #expect(sut.presenter.lastChallengeNames == ["Caminhada", "Leitura", "Sem humor"])
        #expect(sut.presenter.challengesCalls.last?.hasCompletedChallenges == true)
        #expect(sut.presenter.lastArchivedNames == ["Arquivada"])
    }
    
    // Devolver = apagar a marca de arquivado: o sorteio volta a poder sugerir o desafio.
    @Test func testingRestoreChallengeDeletesItAndRefreshesArchivedList() throws {
        let sut = makeChallengesSUT()
        let first = try addChallenge("Arquivada 1", archived: true, in: sut.repository)
        try addChallenge("Arquivada 2", archived: true, in: sut.repository)

        sut.interactor.restoreChallenge(first)

        #expect(try sut.repository.getAll().map(\.name) == ["Arquivada 2"])
        #expect(sut.presenter.lastArchivedNames == ["Arquivada 2"])
        #expect(sut.presenter.errors.isEmpty)
    }

    // MARK: ChallengesInteractor (busca e filtro)

    @Test func testingSearchIgnoresCaseAndAccents() throws {
        let sut = makeChallengesSUT()
        try addChallenge("Meditação guiada", in: sut.repository)
        try addChallenge("Caminhada", in: sut.repository)

        sut.interactor.search("MEDITACAO")

        #expect(sut.presenter.lastChallengeNames == ["Meditação guiada"])
        #expect(sut.interactor.searchText == "MEDITACAO")
    }

    @Test func testingSearchWithOnlySpacesShowsEverything() throws {
        let sut = makeChallengesSUT()
        try addChallenge("Caminhada", in: sut.repository)
        try addChallenge("Leitura", in: sut.repository)

        sut.interactor.search("   ")

        #expect(sut.presenter.lastChallengeNames == ["Caminhada", "Leitura"])
    }

    // Lista vazia, mas existem concluídos: o Presenter precisa saber para mostrar "nenhum encontrado".
    @Test func testingSearchWithoutMatchesStillReportsCompletedChallenges() throws {
        let sut = makeChallengesSUT()
        try addChallenge("Caminhada", in: sut.repository)

        sut.interactor.search("xadrez")

        let call = try #require(sut.presenter.challengesCalls.last)
        #expect(call.activities.isEmpty)
        #expect(call.hasCompletedChallenges)
    }

    @Test func testingToggleCategoryFiltersByCategory() throws {
        let sut = makeChallengesSUT()
        try addChallenge("Caminhada", category: .physical, in: sut.repository)
        try addChallenge("Leitura", category: .cognitive, in: sut.repository)

        sut.interactor.toggleCategory(.cognitive)

        #expect(sut.presenter.lastChallengeNames == ["Leitura"])
        #expect(sut.presenter.challengesCalls.last?.selectedCategory == .cognitive)
    }

    // Tocar de novo no mesmo filtro limpa.
    @Test func testingToggleSameCategoryTwiceClearsFilter() throws {
        let sut = makeChallengesSUT()
        try addChallenge("Caminhada", category: .physical, in: sut.repository)
        try addChallenge("Leitura", category: .cognitive, in: sut.repository)

        sut.interactor.toggleCategory(.cognitive)
        sut.interactor.toggleCategory(.cognitive)

        #expect(sut.interactor.selectedCategory == nil)
        #expect(sut.presenter.challengesCalls.last?.selectedCategory == nil)
        #expect(sut.presenter.lastChallengeNames == ["Caminhada", "Leitura"])
    }

    @Test func testingToggleAnotherCategoryReplacesFilter() throws {
        let sut = makeChallengesSUT()
        try addChallenge("Caminhada", category: .physical, in: sut.repository)
        try addChallenge("Leitura", category: .cognitive, in: sut.repository)

        sut.interactor.toggleCategory(.cognitive)
        sut.interactor.toggleCategory(.physical)

        #expect(sut.interactor.selectedCategory == .physical)
        #expect(sut.presenter.lastChallengeNames == ["Caminhada"])
    }

    // Busca e filtro valem juntos, e continuam valendo quando a tela recarrega.
    @Test func testingSearchAndCategoryCombineAndSurviveReload() throws {
        let sut = makeChallengesSUT()
        try addChallenge("Caminhada no parque", category: .physical, in: sut.repository)
        try addChallenge("Caminhada consciente", category: .sensorial, in: sut.repository)
        try addChallenge("Alongamento", category: .physical, in: sut.repository)

        sut.interactor.toggleCategory(.physical)
        sut.interactor.search("caminhada")
        sut.interactor.loadChallenges()

        #expect(sut.presenter.lastChallengeNames == ["Caminhada no parque"])
    }

    // MARK: ChallengesInteractor (arquivados)

    @Test func testingOpenArchivedRefreshesListAndOpensSheet() throws {
        let sut = makeChallengesSUT()
        try addChallenge("Arquivada", humor: nil, archived: true, in: sut.repository)

        sut.interactor.openArchived()

        #expect(sut.presenter.lastArchivedNames == ["Arquivada"])
        #expect(sut.presenter.archivedSheetStates == [true])
    }

    @Test func testingCloseArchivedClosesSheet() {
        let sut = makeChallengesSUT()

        sut.interactor.closeArchived()

        #expect(sut.presenter.archivedSheetStates == [false])
    }
    
    // Devolvido ao grupo sem resultado: volta para o sorteio, não para a lista de concluídos.
    @Test func testingRestoredChallengeWithoutResultDoesNotAppearAsCompleted() throws {
        let sut = makeChallengesSUT()
        let archived = try addChallenge("Arquivada", humor: nil, archived: true, in: sut.repository)

        sut.interactor.restoreChallenge(archived)
        sut.interactor.loadChallenges()

        #expect(sut.presenter.lastChallengeNames == [])
        #expect(sut.presenter.lastArchivedNames == [])
    }

    @Test func testingRestoreChallengeThatIsNotArchivedDoesNothing() throws {
        let sut = makeChallengesSUT()
        let completed = try addChallenge("Caminhada", in: sut.repository)

        sut.interactor.restoreChallenge(completed)

        #expect(completed.archived == false)
        #expect(sut.presenter.archivedCalls.isEmpty)
    }

    // MARK: ChallengesInteractor (resumo)

    @Test func testingOpenSummaryPresentsActivityAndRemembersIt() throws {
        let sut = makeChallengesSUT()
        let activity = try addChallenge("Caminhada", in: sut.repository)

        sut.interactor.openSummary(activity)

        #expect(sut.presenter.summaries.count == 1)
        #expect(sut.presenter.summaries.first! === activity)
        #expect(sut.interactor.selectedActivity === activity)
    }

    @Test func testingCloseSummaryPresentsNilAndForgetsActivity() throws {
        let sut = makeChallengesSUT()
        let activity = try addChallenge("Caminhada", in: sut.repository)
        sut.interactor.openSummary(activity)

        sut.interactor.closeSummary()

        #expect(sut.presenter.summaries.count == 2)
        #expect(sut.presenter.summaries.last! == nil)
        #expect(sut.interactor.selectedActivity == nil)
    }

    // MARK: ChallengesInteractor (compartilhar)

    @Test func testingChallengesShareStoryWithoutOpenSummaryPresentsError() {
        let sut = makeChallengesSUT()

        sut.interactor.shareStory()

        #expect(sut.presenter.errors.count == 1)
        #expect(sut.presenter.errors.first??.isEmpty == false)
        #expect(sut.presenter.shareSheetURL == nil)
        #expect(sut.share.receivedImage == nil)
    }

    @Test func testingChallengesShareStoryRendersImageAndOpensShareSheet() throws {
        let sut = makeChallengesSUT()
        let activity = try addChallenge("Caminhada", in: sut.repository)
        sut.interactor.openSummary(activity)

        sut.interactor.shareStory()

        #expect(sut.share.receivedImage != nil)
        #expect(sut.presenter.shareSheetURL == sut.share.url)
        #expect(sut.presenter.errors.isEmpty)
    }

    @Test func testingChallengesShareStoryWorkerFailurePresentsError() throws {
        let sut = makeChallengesSUT()
        sut.share.errorToThrow = ShareError.encodingFailed
        let activity = try addChallenge("Caminhada", in: sut.repository)
        sut.interactor.openSummary(activity)

        sut.interactor.shareStory()

        #expect(sut.presenter.errors.count == 1)
        #expect(sut.presenter.shareSheetURL == nil)
    }

    // Depois de fechar o resumo, não há mais o que compartilhar.
    @Test func testingChallengesShareStoryAfterClosingSummaryPresentsError() throws {
        let sut = makeChallengesSUT()
        let activity = try addChallenge("Caminhada", in: sut.repository)
        sut.interactor.openSummary(activity)
        sut.interactor.closeSummary()

        sut.interactor.shareStory()

        #expect(sut.presenter.errors.count == 1)
        #expect(sut.presenter.shareSheetURL == nil)
    }

    @Test(arguments: [true, false])
    func testingChallengesDidFinishSharingPresentsResult(completed: Bool) {
        let sut = makeChallengesSUT()

        sut.interactor.didFinishSharing(completed: completed)

        #expect(sut.presenter.shareFinished == completed)
    }

    @Test func testingDismissErrorClearsMessage() {
        let sut = makeChallengesSUT()

        sut.interactor.dismissError()

        #expect(sut.presenter.errors.count == 1)
        #expect(sut.presenter.errors.first! == nil)
    }
    
    // MARK: ChallengesInteractor (ordenação)

    // Mais recentes primeiro.
    @Test func testingLoadChallengesSortsByMostRecent() throws {
        let sut = makeChallengesSUT()
        let now = Date()
        try addChallenge("Antigo", createdAt: now.addingTimeInterval(-200), in: sut.repository)
        try addChallenge("Novo", createdAt: now, in: sut.repository)
        try addChallenge("Meio", createdAt: now.addingTimeInterval(-100), in: sut.repository)

        sut.interactor.loadChallenges()

        // Sem o `.sorted()` do atalho: aqui a ordem importa.
        #expect(sut.presenter.challengesCalls.last?.activities.map(\.name) == ["Novo", "Meio", "Antigo"])
    }

    // MARK: ChallengesInteractor (tirar outra foto)

    // Primeiro o resumo fecha: a câmera só abre quando o sheet terminou de fechar.
    @Test func testingChallengesRetakePhotoOnlyHidesSummaryAtFirst() throws {
        let sut = makeChallengesSUT()
        let activity = try addChallenge("Caminhada", in: sut.repository)
        sut.interactor.openSummary(activity)

        sut.interactor.retakePhoto()

        #expect(sut.interactor.isRetakingPhoto)
        #expect(sut.presenter.summaries.last! == nil)
        #expect(sut.presenter.cameraStates.isEmpty)
        #expect(sut.camera.startCount == 0)
        // Continua selecionado: é ele que recebe a foto nova.
        #expect(sut.interactor.selectedActivity === activity)
    }

    @Test func testingChallengesSummaryDismissedWhileRetakingOpensCamera() throws {
        let sut = makeChallengesSUT()
        sut.interactor.openSummary(try addChallenge("Caminhada", in: sut.repository))
        sut.interactor.retakePhoto()

        sut.interactor.summaryDismissed()

        #expect(sut.presenter.cameraStates == [true])
        #expect(sut.presenter.flashStates == [false])
        #expect(sut.camera.startCount == 1)
    }

    // O resumo também fecha arrastando: nada de câmera.
    @Test func testingChallengesSummaryDismissedWithoutRetakingDoesNotOpenCamera() {
        let sut = makeChallengesSUT()

        sut.interactor.summaryDismissed()

        #expect(sut.presenter.cameraStates.isEmpty)
        #expect(sut.camera.startCount == 0)
    }

    // Câmera fechada: o mesmo desafio volta para o resumo, uma vez só.
    @Test func testingChallengesCameraDismissedBringsSummaryBack() throws {
        let sut = makeChallengesSUT()
        let activity = try addChallenge("Caminhada", in: sut.repository)
        sut.interactor.openSummary(activity)
        sut.interactor.retakePhoto()
        sut.interactor.summaryDismissed()

        sut.interactor.cameraDismissed()
        sut.interactor.cameraDismissed()

        // abrir, esconder para a câmera, voltar
        #expect(sut.presenter.summaries.count == 3)
        #expect(sut.presenter.summaries.last! === activity)
        #expect(sut.interactor.isRetakingPhoto == false)
    }

    @Test func testingChallengesRetakePhotoWithDeniedPermissionKeepsSummaryOpen() throws {
        let sut = makeChallengesSUT()
        sut.camera.permission = .denied
        sut.interactor.openSummary(try addChallenge("Caminhada", in: sut.repository))

        sut.interactor.retakePhoto()

        #expect(sut.presenter.permissionDeniedCount == 1)
        #expect(sut.interactor.isRetakingPhoto == false)
        #expect(sut.presenter.summaries.count == 1)
    }

    @Test func testingChallengesRetakePhotoAsksPermissionWhenNotDetermined() throws {
        let sut = makeChallengesSUT()
        sut.camera.permission = .notDetermined
        sut.camera.permissionGranted = false
        sut.interactor.openSummary(try addChallenge("Caminhada", in: sut.repository))

        sut.interactor.retakePhoto()

        #expect(sut.camera.requestPermissionCount == 1)
        #expect(sut.presenter.permissionDeniedCount == 1)
    }

    @Test func testingChallengesSessionFailureClosesCameraAndPresentsError() throws {
        let sut = makeChallengesSUT()
        sut.camera.startResult = .failure(CameraError.configurationFailed)
        sut.interactor.openSummary(try addChallenge("Caminhada", in: sut.repository))
        sut.interactor.retakePhoto()

        sut.interactor.summaryDismissed()

        #expect(sut.camera.stopCount == 1)
        #expect(sut.presenter.cameraClosedCount == 1)
        #expect(sut.presenter.cameraErrors.first as? CameraError == .configurationFailed)
    }

    // O ponto principal: a foto nova vai para o desafio e para o banco, e a grade recarrega.
    @Test func testingChallengesTakePhotoSavesPhotoAndReloadsList() throws {
        let sut = makeChallengesSUT()
        let activity = try addChallenge("Caminhada", in: sut.repository)
        activity.result?.photo = Data([9])
        let newPhoto = Data([1, 2, 3])
        sut.camera.captureResult = .success(newPhoto)
        sut.interactor.openSummary(activity)

        sut.interactor.takePhoto()

        #expect(activity.result?.photo == newPhoto)
        #expect(try sut.repository.getAll().first?.result?.photo == newPhoto)
        #expect(sut.camera.stopCount == 1)
        #expect(sut.presenter.cameraClosedCount == 1)
        #expect(sut.presenter.lastChallengeNames == ["Caminhada"])
    }

    // Concluído sem humor também troca a foto; o humor continua `nil`.
    @Test func testingChallengesTakePhotoOnChallengeWithoutHumor() throws {
        let sut = makeChallengesSUT()
        let activity = try addChallenge("Sem humor", humor: nil, in: sut.repository)
        sut.camera.captureResult = .success(Data([1, 2, 3]))
        sut.interactor.openSummary(activity)

        sut.interactor.takePhoto()

        #expect(activity.result?.photo == Data([1, 2, 3]))
        #expect(activity.result?.humor == nil)
    }

    @Test func testingChallengesTakePhotoFailureKeepsOldPhoto() throws {
        let sut = makeChallengesSUT()
        let activity = try addChallenge("Caminhada", in: sut.repository)
        activity.result?.photo = Data([9])
        sut.camera.captureResult = .failure(CameraError.captureFailed)
        sut.interactor.openSummary(activity)

        sut.interactor.takePhoto()

        #expect(activity.result?.photo == Data([9]))
        #expect(sut.presenter.cameraErrors.first as? CameraError == .captureFailed)
        #expect(sut.presenter.cameraClosedCount == 0)
    }

    @Test func testingChallengesTakePhotoUsesCurrentFlash() {
        let sut = makeChallengesSUT()
        sut.interactor.toggleFlash()

        sut.interactor.takePhoto()

        #expect(sut.camera.captureFlashValues == [true])
    }

    @Test func testingChallengesCloseCameraStopsSessionAndClosesScreen() {
        let sut = makeChallengesSUT()

        sut.interactor.closeCamera()

        #expect(sut.camera.stopCount == 1)
        #expect(sut.presenter.cameraClosedCount == 1)
    }

    @Test func testingChallengesSwitchCameraFailurePresentsError() {
        let sut = makeChallengesSUT()
        sut.camera.switchResult = .failure(CameraError.deviceUnavailable)

        sut.interactor.switchCamera()

        #expect(sut.camera.switchCount == 1)
        #expect(sut.presenter.cameraErrors.first as? CameraError == .deviceUnavailable)
    }

    // MARK: - FeelingsInteractor (carregar sentimentos)

    private struct FeelingsSUT {
        let interactor: FeelingsInteractor
        let presenter: FeelingsPresenterSpy
        let repository: GenericRepository<Activity>
        let camera: ConfigurableCameraWorkerMock
        let share: ShareWorkerMock
    }

    private func makeFeelingsSUT() -> FeelingsSUT {
        let presenter = FeelingsPresenterSpy()
        let repository = makeActivityRepository()
        let camera = ConfigurableCameraWorkerMock()
        let share = ShareWorkerMock()
        let interactor = FeelingsInteractor(presenter: presenter, activityRepository: repository, camera: camera, share: share)
        return FeelingsSUT(interactor: interactor, presenter: presenter, repository: repository, camera: camera, share: share)
    }

    /// `humor == nil` cria a atividade sem `ActivityResult`, como ela fica antes de o usuário escolher o humor.
    private func makeFeelingActivity(named name: String, humor: Humor?, archived: Bool = false) -> Activity {
        let result = humor.map { ActivityResult(time: 10, humor: $0) }
        return Activity(category: .physical, result: result, name: name, description: "-", archived: archived)
    }

    @Test func testingLoadFeelingsWithEmptyDatabasePresentsEmptyList() {
        let sut = makeFeelingsSUT()

        sut.interactor.loadFeelings()

        #expect(sut.presenter.presentedActivities.count == 1)
        #expect(sut.presenter.presentedActivities.first?.isEmpty == true)
    }

    // Atividades sem resultado (em andamento, abandonadas ou arquivadas) não entram nos sentimentos.
    @Test func testingLoadFeelingsPresentsOnlyActivitiesWithResult() throws {
        let sut = makeFeelingsSUT()
        try sut.repository.add(makeFeelingActivity(named: "Caminhada", humor: .pleasant))
        try sut.repository.add(makeFeelingActivity(named: "Leitura", humor: .veryPleasant))
        try sut.repository.add(makeFeelingActivity(named: "Sem resultado", humor: nil))
        try sut.repository.add(makeFeelingActivity(named: "Arquivada", humor: nil, archived: true))

        sut.interactor.loadFeelings()

        let presented = try #require(sut.presenter.presentedActivities.first)
        #expect(presented.map(\.name).sorted() == ["Caminhada", "Leitura"])
    }

    @Test func testingLoadFeelingsWithOnlyUnfinishedActivitiesPresentsEmptyList() throws {
        let sut = makeFeelingsSUT()
        try sut.repository.add(makeFeelingActivity(named: "Sem resultado", humor: nil))

        sut.interactor.loadFeelings()

        #expect(sut.presenter.presentedActivities.count == 1)
        #expect(sut.presenter.presentedActivities.first?.isEmpty == true)
    }

    @Test func testingLoadFeelingsPresentsTheSameActivitiesStoredInRepository() throws {
        let sut = makeFeelingsSUT()
        let activity = makeFeelingActivity(named: "Caminhada", humor: .pleasant)
        try sut.repository.add(activity)

        sut.interactor.loadFeelings()

        let presented = try #require(sut.presenter.presentedActivities.first)
        #expect(presented.first === activity)
        #expect(presented.first?.result?.humor == .pleasant)
    }

    // A tela chama `loadFeelings()` toda vez que aparece: cada chamada tem que refletir o banco naquele momento.
    @Test func testingLoadFeelingsReflectsActivitiesAddedBetweenCalls() throws {
        let sut = makeFeelingsSUT()
        try sut.repository.add(makeFeelingActivity(named: "Caminhada", humor: .pleasant))
        sut.interactor.loadFeelings()

        try sut.repository.add(makeFeelingActivity(named: "Leitura", humor: .veryPleasant))
        sut.interactor.loadFeelings()

        #expect(sut.presenter.presentedActivities.map(\.count) == [1, 2])
    }

    // MARK: - FeelingsInteractor (selecionar e apagar)

    @Test func testingSelectActivityPresentsTheSelectedActivity() throws {
        let sut = makeFeelingsSUT()
        let activity = makeFeelingActivity(named: "Caminhada", humor: .calm)
        try sut.repository.add(activity)

        sut.interactor.selectActivity(activity: activity)

        #expect(sut.presenter.selectedActivities.count == 1)
        #expect(sut.presenter.selectedActivities.first === activity)
        #expect(sut.interactor.selectedActivity === activity)
    }

    // Depois de apagar, a lista é recarregada sem a atividade apagada.
    @Test func testingDeleteActivityRemovesItAndReloadsFeelings() throws {
        let sut = makeFeelingsSUT()
        let walk = makeFeelingActivity(named: "Caminhada", humor: .calm)
        let read = makeFeelingActivity(named: "Leitura", humor: .chill)
        try sut.repository.add(walk)
        try sut.repository.add(read)

        sut.interactor.deleteActivity(activity: walk)

        #expect(try sut.repository.getAll().map(\.name) == ["Leitura"])
        #expect(sut.presenter.presentedActivities.last?.map(\.name) == ["Leitura"])
    }

    // MARK: - FeelingsInteractor (tirar outra foto)

    // Primeiro o detalhe fecha: a câmera só abre quando o sheet terminou de fechar.
    @Test func testingRetakePhotoWithPermissionOnlyHidesDetailAtFirst() {
        let sut = makeFeelingsSUT()

        sut.interactor.retakePhoto()

        #expect(sut.presenter.detailVisibilityChanges == [false])
        #expect(sut.interactor.isRetakingPhoto)
        #expect(sut.presenter.cameraPresentedCount == 0)
        #expect(sut.camera.startCount == 0)
        #expect(sut.presenter.permissionDeniedCount == 0)
    }

    @Test func testingDetailDismissedWhileRetakingOpensCameraAndStartsSession() {
        let sut = makeFeelingsSUT()
        sut.interactor.retakePhoto()

        sut.interactor.detailDismissed()

        #expect(sut.presenter.cameraPresentedCount == 1)
        #expect(sut.camera.startCount == 1)
    }

    // O sheet também fecha por conta própria (arrastando, ou no "xmark"): nada de câmera.
    @Test func testingDetailDismissedWithoutRetakingDoesNotOpenCamera() {
        let sut = makeFeelingsSUT()

        sut.interactor.detailDismissed()

        #expect(sut.presenter.cameraPresentedCount == 0)
        #expect(sut.camera.startCount == 0)
    }

    // O flash atual é mostrado assim que a câmera abre.
    @Test func testingDetailDismissedWhileRetakingPresentsCurrentFlashState() {
        let sut = makeFeelingsSUT()
        sut.interactor.retakePhoto()

        sut.interactor.detailDismissed()

        #expect(sut.presenter.flashStates == [false])
    }

    // Câmera fechada (com foto ou sem): o detalhe volta, uma vez só.
    @Test func testingCameraDismissedWhileRetakingBringsDetailBack() {
        let sut = makeFeelingsSUT()
        sut.interactor.retakePhoto()
        sut.interactor.detailDismissed()

        sut.interactor.cameraDismissed()
        sut.interactor.cameraDismissed()

        #expect(sut.presenter.detailVisibilityChanges == [false, true])
        #expect(sut.interactor.isRetakingPhoto == false)
    }

    @Test func testingCameraDismissedWithoutRetakingKeepsDetailAsIs() {
        let sut = makeFeelingsSUT()

        sut.interactor.cameraDismissed()

        #expect(sut.presenter.detailVisibilityChanges.isEmpty)
    }

    @Test func testingRetakePhotoWithDeniedPermissionPresentsDeniedAndKeepsCameraOff() {
        let sut = makeFeelingsSUT()
        sut.camera.permission = .denied

        sut.interactor.retakePhoto()

        #expect(sut.presenter.permissionDeniedCount == 1)
        #expect(sut.presenter.cameraPresentedCount == 0)
        #expect(sut.camera.startCount == 0)
        // O detalhe fica aberto para mostrar o alerta.
        #expect(sut.presenter.detailVisibilityChanges.isEmpty)
        #expect(sut.interactor.isRetakingPhoto == false)
    }

    @Test func testingRetakePhotoAsksPermissionWhenNotDeterminedAndGranted() {
        let sut = makeFeelingsSUT()
        sut.camera.permission = .notDetermined
        sut.camera.permissionGranted = true

        sut.interactor.retakePhoto()
        sut.interactor.detailDismissed()

        #expect(sut.camera.requestPermissionCount == 1)
        #expect(sut.presenter.cameraPresentedCount == 1)
        #expect(sut.camera.startCount == 1)
    }

    @Test func testingRetakePhotoAsksPermissionWhenNotDeterminedAndRefused() {
        let sut = makeFeelingsSUT()
        sut.camera.permission = .notDetermined
        sut.camera.permissionGranted = false

        sut.interactor.retakePhoto()

        #expect(sut.camera.requestPermissionCount == 1)
        #expect(sut.presenter.permissionDeniedCount == 1)
        #expect(sut.camera.startCount == 0)
        #expect(sut.presenter.detailVisibilityChanges.isEmpty)
    }

    // Se a sessão não liga, a tela fecha e o erro aparece.
    @Test func testingRetakePhotoWhenSessionFailsClosesCameraAndPresentsError() {
        let sut = makeFeelingsSUT()
        sut.camera.startResult = .failure(CameraError.deviceUnavailable)

        sut.interactor.retakePhoto()
        sut.interactor.detailDismissed()

        #expect(sut.presenter.cameraClosedCount == 1)
        #expect(sut.camera.stopCount == 1)
        #expect(sut.presenter.presentedErrors.count == 1)
    }

    @Test func testingCloseCameraStopsSessionAndClosesScreen() {
        let sut = makeFeelingsSUT()

        sut.interactor.closeCamera()

        #expect(sut.camera.stopCount == 1)
        #expect(sut.presenter.cameraClosedCount == 1)
    }

    // Fechar sem fotografar não pode mexer na foto que a atividade já tinha.
    @Test func testingCloseCameraKeepsTheCurrentPhoto() throws {
        let sut = makeFeelingsSUT()
        let activity = makeFeelingActivity(named: "Caminhada", humor: .calm)
        activity.result?.photo = Data([9])
        try sut.repository.add(activity)
        sut.interactor.selectActivity(activity: activity)

        sut.interactor.retakePhoto()
        sut.interactor.closeCamera()

        #expect(activity.result?.photo == Data([9]))
        #expect(sut.presenter.photoUpdates.isEmpty)
    }

    @Test func testingToggleFlashAlternatesAndPresentsEachState() {
        let sut = makeFeelingsSUT()

        sut.interactor.toggleFlash()
        sut.interactor.toggleFlash()

        #expect(sut.presenter.flashStates == [true, false])
    }

    @Test func testingSwitchCameraFailurePresentsError() {
        let sut = makeFeelingsSUT()
        sut.camera.switchResult = .failure(CameraError.configurationFailed)

        sut.interactor.switchCamera()

        #expect(sut.camera.switchCount == 1)
        #expect(sut.presenter.presentedErrors.count == 1)
    }

    @Test func testingSwitchCameraSuccessPresentsNothing() {
        let sut = makeFeelingsSUT()

        sut.interactor.switchCamera()

        #expect(sut.presenter.presentedErrors.isEmpty)
    }

    // O ponto principal da feature: a foto nova substitui a antiga e vai para o banco.
    @Test func testingTakePhotoReplacesActivityPhotoAndPresentsUpdate() throws {
        let sut = makeFeelingsSUT()
        let activity = makeFeelingActivity(named: "Caminhada", humor: .calm)
        activity.result?.photo = Data([9])
        try sut.repository.add(activity)
        sut.interactor.selectActivity(activity: activity)
        let newPhoto = Data([1, 2, 3])
        sut.camera.captureResult = .success(newPhoto)

        sut.interactor.takePhoto()

        #expect(activity.result?.photo == newPhoto)
        #expect(try sut.repository.getAll().first?.result?.photo == newPhoto)
        #expect(sut.presenter.photoUpdates == [newPhoto])
        #expect(sut.camera.stopCount == 1)
    }

    // O story usa a foto, então precisa ser gerado de novo com a nova.
    @Test func testingTakePhotoRendersTheStoryAgain() throws {
        let sut = makeFeelingsSUT()
        let activity = makeFeelingActivity(named: "Caminhada", humor: .calm)
        try sut.repository.add(activity)
        sut.interactor.selectActivity(activity: activity)

        sut.interactor.takePhoto()

        #expect(sut.presenter.storyActivities.count == 1)
        #expect(sut.presenter.storyActivities.first === activity)
    }

    @Test func testingTakePhotoUsesCurrentFlashState() {
        let sut = makeFeelingsSUT()
        sut.interactor.toggleFlash()

        sut.interactor.takePhoto()

        #expect(sut.camera.captureFlashValues == [true])
    }

    @Test func testingTakePhotoFailurePresentsErrorAndKeepsPhoto() throws {
        let sut = makeFeelingsSUT()
        let activity = makeFeelingActivity(named: "Caminhada", humor: .calm)
        activity.result?.photo = Data([9])
        try sut.repository.add(activity)
        sut.interactor.selectActivity(activity: activity)
        sut.camera.captureResult = .failure(CameraError.captureFailed)

        sut.interactor.takePhoto()

        #expect(sut.presenter.presentedErrors.count == 1)
        #expect(sut.presenter.photoUpdates.isEmpty)
        #expect(activity.result?.photo == Data([9]))
    }

    // Sem atividade selecionada não há onde guardar a foto: nada quebra.
    @Test func testingTakePhotoWithoutSelectedActivityDoesNotCrash() {
        let sut = makeFeelingsSUT()

        sut.interactor.takePhoto()

        #expect(sut.presenter.storyActivities.isEmpty)
    }

    @Test func testingDismissAlertsAsksPresenterToClearThem() {
        let sut = makeFeelingsSUT()

        sut.interactor.dismissAlerts()

        #expect(sut.presenter.alertsDismissedCount == 1)
    }

    // MARK: - FeelingsInteractor (compartilhar)

    private func makeStoryImage() -> UIImage {
        UIGraphicsImageRenderer(size: CGSize(width: 4, height: 4)).image { _ in }
    }

    @Test func testingShareStoryWritesFileAndPresentsShareSheet() {
        let sut = makeFeelingsSUT()
        let image = makeStoryImage()

        sut.interactor.shareStory(image)

        #expect(sut.share.receivedImage === image)
        #expect(sut.presenter.shareSheetURL == sut.share.url)
        #expect(sut.presenter.presentedErrors.isEmpty)
    }

    // Imagem nula = a renderização falhou: mostra o erro em vez de abrir um sheet vazio.
    @Test func testingShareStoryWithoutImagePresentsRenderError() {
        let sut = makeFeelingsSUT()

        sut.interactor.shareStory(nil)

        #expect(sut.presenter.shareSheetURL == nil)
        #expect(sut.presenter.presentedErrors.first as? ShareError == .renderFailed)
    }

    @Test func testingShareStoryWhenWorkerFailsPresentsErrorAndNoSheet() {
        let sut = makeFeelingsSUT()
        sut.share.errorToThrow = ShareError.encodingFailed

        sut.interactor.shareStory(makeStoryImage())

        #expect(sut.presenter.shareSheetURL == nil)
        #expect(sut.presenter.presentedErrors.first as? ShareError == .encodingFailed)
    }

    @Test(arguments: [true, false])
    func testingDidFinishSharingPresentsResult(completed: Bool) {
        let sut = makeFeelingsSUT()

        sut.interactor.didFinishSharing(completed: completed)

        #expect(sut.presenter.shareFinished == completed)
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
