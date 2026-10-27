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
    
    // Sorteio
    func presentChallenge(_ challenge: FrictionChallenge) { events.append(.challenge(title: challenge.title)) }
    func presentSearching() { events.append(.searching) }
    func presentSearchFailed() { events.append(.searchFailed) }
    
    // Fora do escopo dos testes de sorteio
    func presentAcceptedActivity() {}
    func presentStartAgain() {}
    func presentMood() {}
    func presentPhoto() {}
    func presentCamera() {}
    func presentCameraClosed() {}
    func presentPermissionDenied() {}
    func presentCaptured(_ data: Data) {}
    func presentFlash(isOn: Bool) {}
    func presentError(_ error: Error) {}
    func presentAlertsDismissed() {}
    func presentSummary() {}
    func presentFlowFinished() {}
    func presentInProgress() {}
    func presentChallenge() {}
    func presentDraw() {}
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
        let repository: GenericRepository<Activity>
    }
    
    private func makeActivitySUT() -> ActivitySUT {
        let presenter = ActivityPresenterSpy()
        let foundation = FoundationWorkerMock()
        let haptics = HapticsWorkerMock()
        let motion = CoreMotionWorkerMock()
        let repository = makeActivityRepository()
        let interactor = ActivityInteractor(
            presenter: presenter,
            activityRepository: repository,
            hapticWorker: haptics,
            coreMotionWorker: motion,
            foundationWorker: foundation,
            camera: CameraWorkerMock()
        )
        return ActivitySUT(interactor: interactor, presenter: presenter, foundation: foundation,
                            haptics: haptics, motion: motion, repository: repository)
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
        
        sut.interactor.archiveChallenge(title: "Cardio sem fones", description: "Faça cardio", in: .physical)
        
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
