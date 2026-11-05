//
//  PresenterTests.swift
//  ChallengeFinalTests
//
//  Created by Paulo Henrique Costa Alves on 19/10/26.
//

import Foundation
import Testing
import SwiftData
import UIKit
@testable import ChallengeFinal
//
//// MARK: - Spies (test doubles for the Interactor protocols the Presenters talk to)
//
//
//final class ActivitiesInteractorSpy: ActivitiesInteractorProtocol {
//    private(set) var fetchHistoryCallCount = 0
//    private(set) var generatedActivityGroup: Group?
//    func generateActivity(for group: Group) {
//        generatedActivityGroup = group
//    }
//    func acceptActivity(_ activity: Activity) {}
//    func refuseActivityTemporarily(_ activity: Activity) {}
//    func refuseActivityPermanently(_ activity: Activity) {}
//    func concludeActivity(_ activity: Activity, result: Results) {}
//    func fetchHistory() {
//        fetchHistoryCallCount += 1
//    }
//}
//
//final class ProfileInteractorSpy: ProfileInteractorProtocol {
//    private(set) var fetchProfileCallCount = 0
//    private(set) var updatedTheme: Theme?
//    func fetchProfile() {
//        fetchProfileCallCount += 1
//    }
//    func updateLocalizable(_ enabled: Bool) {}
//    func updateNotifications(_ enabled: Bool) {}
//    func updateTheme(_ theme: Theme) {
//        updatedTheme = theme
//    }
//    func updateBackgroundActivity(_ enabled: Bool) {}
//}
//
@Suite("Tests for all presenters in the project")
@MainActor
struct PresenterTests {
    
    // MARK: - Auxiliadores
    
    // O presenter guarda o store como weak, então o teste precisa segurar o store (por isso devolvemos os dois).
    private func createPresenterAndStore() -> (presenter: HomePresenter, store: HomeStore) {
        let store = HomeStore(coordinator: HomeCoordinator())
        let presenter = HomePresenter(store: store)
        return (presenter, store)
    }

    // MARK: - HomePresenter

    @Test func testingPresentCategoryUpdatesStore() {
        let (presenter, store) = createPresenterAndStore()
        
        presenter.presentCategory(.cognitive)
        
        #expect(store.currentCategory == .cognitive)
        
        presenter.presentCategory(.physical)
        
        #expect(store.currentCategory == .physical)
    }
    
    @Test func testingPresentWeekUpdatesStore() {
        let (presenter, store) = createPresenterAndStore()
        
        // 18/10/2026 é domingo, então a semana vai de domingo a sábado.
        let calendar = Calendar.current
        let sunday = calendar.date(from: DateComponents(year: 2026, month: 10, day: 18))!
        let days = (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: sunday) }
        
        presenter.presentWeek(days: days)
        
        #expect(store.daysOfWeek == ["D", "S", "T", "Q", "Q", "S", "S"])
    }

    // MARK: - ActivityPresenter (sorteio de desafios)
    
    // Mesmo cuidado do Home: o presenter guarda o store como weak, então o teste segura o store.
    private func createActivityPresenterAndStore() -> (presenter: ActivityPresenter, store: ActivityStore) {
        let coordinator = ActivityCoordinator(selectedCategory: .physical, onFinish: {})
        let store = ActivityStore(coordinator: coordinator)
        let presenter = ActivityPresenter(store: store)
        return (presenter, store)
    }
    
    // SwiftData precisa de um container carregado para criar o `ActivityResult`.
    let modelContainer: ModelContainer = {
        let schema = Schema([Activity.self, ActivityResult.self, Profile.self])
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        return try! ModelContainer(for: schema, configurations: config)
    }()
    
    @Test func testingPresentSearchingMarksStoreAsSearching() {
        let (presenter, store) = createActivityPresenterAndStore()
        
        presenter.presentSearching()
        
        #expect(store.isSearching == true)
    }
    
    @Test func testingPresentChallengeFillsStoreAndMarksReady() {
        let (presenter, store) = createActivityPresenterAndStore()
        presenter.presentSearching()
        let challenge = FrictionChallenge(title: "respire fundo", subTitle: "Pausa", rationale: "Respire por um minuto.")
        
        presenter.presentActivity(challenge)
        
        #expect(store.activityTitle == "respire fundo")
        #expect(store.activitySubtitle == "Pausa")
        #expect(store.activityDescription == "Respire por um minuto.")
        #expect(store.isChallengeReady == true)
        #expect(store.isSearching == false)
    }
    
    @Test func testingPresentSearchFailedStopsSearchingWithoutChallenge() {
        let (presenter, store) = createActivityPresenterAndStore()
        presenter.presentSearching()
        
        presenter.presentSearchFailed()
        
        #expect(store.isSearching == false)
        #expect(store.isChallengeReady == false)
        #expect(store.activityTitle == nil)
    }
    
    @Test func testingPresentAcceptedActivityMarksChallengeAsAccepted() {
        let (presenter, store) = createActivityPresenterAndStore()
        
        presenter.presentAcceptedActivity()
        
        #expect(store.isChallengeAccepted == true)
    }
    
    @Test func testingPresentStartAgainClearsRaffleState() {
        let (presenter, store) = createActivityPresenterAndStore()
        presenter.presentActivity(FrictionChallenge(title: "t", subTitle: "s", rationale: "r"))
        presenter.presentAcceptedActivity()
        
        presenter.presentStartAgain()
        
        #expect(store.isChallengeReady == false)
        #expect(store.isChallengeAccepted == false)
        #expect(store.isSearching == false)
    }

    // MARK: ActivityPresenter (cronômetro)

    // Cada par é (segundos recebidos do Interactor, texto esperado na Store).
    @Test(arguments: [
        (TimeInterval(0), "00:00:00"),
        (TimeInterval(5), "00:00:05"),
        (TimeInterval(65), "00:01:05"),
        (TimeInterval(3725), "01:02:05"),
        (TimeInterval(36000), "10:00:00"),
        (TimeInterval(59.9), "00:00:59")     
    ])
    func testingPresentTimeFormatsHoursMinutesAndSeconds(elapsed: TimeInterval, expected: String) {
        let (presenter, store) = createActivityPresenterAndStore()

        presenter.presentTime(elapsed)

        #expect(store.timeText == expected)
    }

    @Test func testingPresentTimeReplacesPreviousTime() {
        let (presenter, store) = createActivityPresenterAndStore()
        presenter.presentTime(3725)

        presenter.presentTime(0)

        #expect(store.timeText == "00:00:00")
    }
    
    // MARK: ActivityPresenter (humor)

    @Test func testingPresentHumorUpdatesStore() {
        let (presenter, store) = createActivityPresenterAndStore()

        presenter.presentHumor(.veryUnpleasant)

        #expect(store.humor == .veryUnpleasant)
    }

    // MARK: ActivityPresenter (compartilhamento)

    @Test func testingPresentStoryRendersStoryImage() throws {
        let (presenter, store) = createActivityPresenterAndStore()
        let result = ActivityResult(time: 0, humor: .veryPleasant)

        presenter.presentStory(result, title: "faça o seu cardio", subtitle: "menos distração", description: "sem redes sociais")

        // O story sai em 1080x1920 px (360x640 pt com scale 3).
        let image = try #require(store.storyImage)
        #expect(image.size.width * image.scale == 1080)
        #expect(image.size.height * image.scale == 1920)
    }

    @Test func testingPresentShareSheetOpensAndCloses() {
        let (presenter, store) = createActivityPresenterAndStore()
        let url = URL(fileURLWithPath: "/tmp/Desafio-Concluído.png")

        presenter.presentShareSheet(fileURL: url)
        #expect(store.shareItem?.activityItems.first as? URL == url)

        presenter.presentShareFinished(completed: true)
        #expect(store.shareItem == nil)
    }

    @Test func testingPresentShareErrorShowsMessage() {
        let (presenter, store) = createActivityPresenterAndStore()

        presenter.presentError(ShareError.renderFailed)

        #expect(store.errorMessage == "Não foi possível preparar a imagem para compartilhar. Tente novamente.")
    }
    // MARK: - FeelingsPresenter (agrupar por humor)

    // Mesmo cuidado dos outros: o presenter guarda o store como weak, então o teste segura o store.
    private func createFeelingsPresenterAndStore() -> (presenter: FeelingsPresenter, store: FeelingsStore) {
        let store = FeelingsStore()
        let presenter = FeelingsPresenter(store: store)
        return (presenter, store)
    }

    /// `humor == nil` cria a atividade sem `ActivityResult`.
    private func makeFeelingActivity(named name: String, humor: Humor?) -> Activity {
        let result = humor.map { ActivityResult(time: 10, humor: $0) }
        return Activity(category: .physical, result: result, name: name, description: "-", archived: false)
    }

    @Test func testingPresentFeelingsLoadedGroupsActivitiesByHumor() {
        let (presenter, store) = createFeelingsPresenterAndStore()
        let activities = [
            makeFeelingActivity(named: "A", humor: .pleasant),
            makeFeelingActivity(named: "B", humor: .veryPleasant),
            makeFeelingActivity(named: "C", humor: .pleasant)
        ]

        presenter.presentFeelingsLoaded(activities: activities)

        // A ordem original é mantida dentro de cada grupo.
        #expect(store.feelings[.pleasant]?.map(\.name) == ["A", "C"])
        #expect(store.feelings[.veryPleasant]?.map(\.name) == ["B"])
        #expect(store.feelings.count == 2)
    }

    @Test func testingPresentFeelingsLoadedLeavesOutHumorsWithoutActivities() {
        let (presenter, store) = createFeelingsPresenterAndStore()

        presenter.presentFeelingsLoaded(activities: [makeFeelingActivity(named: "A", humor: .pleasant)])

        // A View usa `?? 0` para esses humores.
        #expect(store.feelings[.unpleasant] == nil)
        #expect(store.feelings[.veryUnpleasant] == nil)
    }

    @Test func testingPresentFeelingsLoadedWithNoActivitiesLeavesStoreEmpty() {
        let (presenter, store) = createFeelingsPresenterAndStore()

        presenter.presentFeelingsLoaded(activities: [])

        #expect(store.feelings.isEmpty)
    }

    @Test func testingPresentFeelingsLoadedIgnoresActivitiesWithoutResult() {
        let (presenter, store) = createFeelingsPresenterAndStore()
        let activities = [
            makeFeelingActivity(named: "Sem resultado", humor: nil),
            makeFeelingActivity(named: "Caminhada", humor: .pleasant)
        ]

        presenter.presentFeelingsLoaded(activities: activities)

        #expect(store.feelings.count == 1)
        #expect(store.feelings[.pleasant]?.map(\.name) == ["Caminhada"])
    }

    @Test func testingPresentFeelingsLoadedKeepsTheSameActivityInstances() {
        let (presenter, store) = createFeelingsPresenterAndStore()
        let activity = makeFeelingActivity(named: "Caminhada", humor: .pleasant)

        presenter.presentFeelingsLoaded(activities: [activity])

        #expect(store.feelings[.pleasant]?.first === activity)
    }

    @Test(arguments: Humor.allCases)
    func testingPresentFeelingsLoadedUsesActivityHumorAsKey(humor: Humor) {
        let (presenter, store) = createFeelingsPresenterAndStore()

        presenter.presentFeelingsLoaded(activities: [makeFeelingActivity(named: "A", humor: humor)])

        #expect(Array(store.feelings.keys) == [humor])
    }

    // Cada carga substitui a anterior, não soma.
    @Test func testingPresentFeelingsLoadedReplacesPreviousFeelings() {
        let (presenter, store) = createFeelingsPresenterAndStore()
        presenter.presentFeelingsLoaded(activities: [makeFeelingActivity(named: "A", humor: .pleasant)])

        presenter.presentFeelingsLoaded(activities: [makeFeelingActivity(named: "B", humor: .veryPleasant)])

        #expect(store.feelings[.pleasant] == nil)
        #expect(store.feelings[.veryPleasant]?.map(\.name) == ["B"])
    }

    // O store é weak: se a tela já foi embora, apresentar não pode quebrar.
    @Test func testingPresentFeelingsLoadedWithoutStoreDoesNotCrash() {
        let presenter: FeelingsPresenter
        do {
            let store = FeelingsStore()
            presenter = FeelingsPresenter(store: store)
        }

        presenter.presentFeelingsLoaded(activities: [makeFeelingActivity(named: "A", humor: .pleasant)])

        #expect(presenter.store == nil)
    }

//    // MARK: - ProfilePresenter
//
//    @Test func testingProfileFetchDataDelegatesToInteractor() async throws {
//        let interactorSpy = ProfileInteractorSpy()
//        let store = ProfileStore()
//        let presenter = ProfilePresenter(interactor: interactorSpy, store: store)
//
//        presenter.fetchData()
//
//        #expect(interactorSpy.fetchProfileCallCount == 1)
//    }
//
//    @Test func testingPresentProfileUpdatesStoreAndPresenter() async throws {
//        let interactorSpy = ProfileInteractorSpy()
//        let store = ProfileStore()
//        let presenter = ProfilePresenter(interactor: interactorSpy, store: store)
//        let profile = Profile(profileID: UUID(), profilePicture: Data(), name: "Paulo", localizable: true, notifications: true, theme: .themeTwo, backgroundActivity: false, streak: 5)
//
//        presenter.presentProfile(profile)
//
//        #expect(store.currentProfile.profileID == profile.profileID)
//        #expect(presenter.currentProfile.streak == 5)
//    }
}
