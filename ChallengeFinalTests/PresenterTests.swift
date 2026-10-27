//
//  PresenterTests.swift
//  ChallengeFinalTests
//
//  Created by Paulo Henrique Costa Alves on 19/10/26.
//

import Foundation
import Testing
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
