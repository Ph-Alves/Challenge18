//
//  StoreTests.swift
//  ChallengeFinalTests
//
//  Created by Paulo Henrique Costa Alves on 19/10/26.
//

import Foundation
import Testing
import SwiftData
@testable import ChallengeFinal

@Suite("Tests for all stores in the project")
@MainActor
struct StoreTests {
    // MARK: - Auxiliadores
    
    private func createHomeStore() -> HomeStore {
        HomeStore(coordinator: HomeCoordinator())
    }
    
    // MARK: - HomeStore

    @Test func testingHomeStoreStartsWithDefaultState() {
        let store = createHomeStore()

        #expect(store.currentCategory == .physical)
        #expect(store.daysOfWeek.isEmpty)
    }

    @Test(arguments: ActivityCategory.allCases)
    func testingDisplayCategoryUpdatesCurrentCategory(category: ActivityCategory) {
        let store = createHomeStore()

        store.displayCategory(category)

        #expect(store.currentCategory == category)
    }
    
    @Test func testingDisplayWeekUpdatesDaysOfWeek() {
        let store = createHomeStore()
        let week = ["D", "S", "T", "Q", "Q", "S", "S"]

        store.displayWeek(days: week)

        #expect(store.daysOfWeek == week)
    }
    
    @Test func testingDisplayWeekReplacesPreviousDays() {
        let store = createHomeStore()
        store.displayWeek(days: ["D", "S", "T", "Q", "Q", "S", "S"])

        store.displayWeek(days: [])

        #expect(store.daysOfWeek.isEmpty)
    }

    // MARK: - ActivityStore (sorteio de desafios)
    
    private func createActivityStore() -> (store: ActivityStore, coordinator: ActivityCoordinator) {
        let coordinator = ActivityCoordinator(selectedCategory: .physical, onFinish: {})
        return (ActivityStore(coordinator: coordinator), coordinator)
    }
    
    @Test func testingActivityStoreStartsWithDefaultState() {
        let (store, _) = createActivityStore()
        
        #expect(store.activityTitle == nil)
        #expect(store.activitySubtitle == nil)
        #expect(store.activityDescription == nil)
        #expect(store.isSearching == false)
        #expect(store.isChallengeReady == false)
        #expect(store.isChallengeAccepted == false)
        #expect(store.currentStep == .draw)
    }
    
    @Test func testingDisplayChallengeStoresFieldsAndMarksReady() {
        let (store, _) = createActivityStore()
        store.displaySearching()
        
        store.displayActivity(FrictionChallenge(title: "título", subTitle: "sub", rationale: "descrição"))
        
        #expect(store.activityTitle == "título")
        #expect(store.activitySubtitle == "sub")
        #expect(store.activityDescription == "descrição")
        #expect(store.isChallengeReady == true)
        #expect(store.isSearching == false)
    }
    
    @Test func testingDisplaySearchingAlsoUndoesAccepted() {
        let (store, _) = createActivityStore()
        store.displayAcceptedActivity()
        
        store.displaySearching()
        
        #expect(store.isSearching == true)
        #expect(store.isChallengeAccepted == false)
    }
    
    @Test func testingDisplaySearchFailedStopsSearching() {
        let (store, _) = createActivityStore()
        store.displaySearching()
        
        store.displaySearchFailed()
        
        #expect(store.isSearching == false)
    }
    
    @Test func testingTransitionToStartResetsStateAndGoesToChallenge() {
        let (store, coordinator) = createActivityStore()
        store.displayActivity(FrictionChallenge(title: "t", subTitle: "s", rationale: "r"))
        store.displayAcceptedActivity()
        
        store.transitionToStart()
        
        #expect(store.isSearching == false)
        #expect(store.isChallengeReady == false)
        #expect(store.isChallengeAccepted == false)
        #expect(coordinator.step == .challenge)
    }
    
    @Test func testingTransitionsForwardToCoordinator() {
        let (store, coordinator) = createActivityStore()
        
        store.transitionToMood()
        #expect(coordinator.step == .mood)
        
        store.transitionToPhoto()
        #expect(coordinator.step == .photo)
        
        store.transitionToActivity()
        #expect(coordinator.step == .challenge)
        
        store.transitionToInProgress()
        #expect(store.currentStep == .inProgress)
        
        store.transitionToDraw()
        #expect(store.currentStep == .draw)
    }

    // MARK: ActivityStore (cronômetro)

    @Test func testingActivityStoreStartsWithZeroedTime() {
        let (store, _) = createActivityStore()

        #expect(store.timeText == "00:00:00")
    }

    @Test func testingDisplayTimerUpdatesTimeText() {
        let (store, _) = createActivityStore()

        store.displayTimer("01:02:05")

        #expect(store.timeText == "01:02:05")
    }

    @Test func testingDisplayTimerReplacesPreviousTime() {
        let (store, _) = createActivityStore()
        store.displayTimer("01:02:05")

        store.displayTimer("00:00:00")

        #expect(store.timeText == "00:00:00")
    }
    // MARK: - FeelingsStore

    // SwiftData precisa de um container carregado para criar `Activity` e `ActivityResult`.
    let modelContainer: ModelContainer = {
        let schema = Schema([Activity.self, ActivityResult.self, Profile.self])
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        return try! ModelContainer(for: schema, configurations: config)
    }()

    private func makeFeelingActivity(named name: String, humor: Humor) -> Activity {
        let result = ActivityResult(time: 10, humor: humor)
        return Activity(category: .physical, result: result, name: name, description: "-", archived: false)
    }

    @Test func testingFeelingsStoreStartsEmpty() {
        let store = FeelingsStore()

        #expect(store.feelings.isEmpty)
    }

    @Test func testingPresentFeelingsLoadedStoresFeelings() {
        let store = FeelingsStore()
        let walk = makeFeelingActivity(named: "Caminhada", humor: .calm)
        let read = makeFeelingActivity(named: "Leitura", humor: .chill)

        store.presentFeelingsLoaded(feelings: [.calm: [walk], .chill: [read]])

        #expect(store.feelings.count == 2)
        #expect(store.feelings[.calm]?.first === walk)
        #expect(store.feelings[.chill]?.first === read)
    }

    @Test func testingPresentFeelingsLoadedReplacesPreviousFeelings() {
        let store = FeelingsStore()
        store.presentFeelingsLoaded(feelings: [.calm: [makeFeelingActivity(named: "Caminhada", humor: .calm)]])

        store.presentFeelingsLoaded(feelings: [.chill: [makeFeelingActivity(named: "Leitura", humor: .chill)]])

        #expect(store.feelings[.calm] == nil)
        #expect(store.feelings[.chill]?.count == 1)
    }

    @Test func testingPresentFeelingsLoadedWithEmptyDictionaryClearsStore() {
        let store = FeelingsStore()
        store.presentFeelingsLoaded(feelings: [.calm: [makeFeelingActivity(named: "Caminhada", humor: .calm)]])

        store.presentFeelingsLoaded(feelings: [:])

        #expect(store.feelings.isEmpty)
    }

//    // MARK: - ProfileStore
//
//    @Test func testingProfileStoreStartsWithDefaultProfile() async throws {
//        let store = ProfileStore()
//
//        #expect(store.currentProfile.streak == 0)
//        #expect(store.currentProfile.theme == .themeOne)
//    }
//
//    @Test func testingProfileStoreHoldsAssignedProfile() async throws {
//        let store = ProfileStore()
//        let profile = Profile(profileID: UUID(), profilePicture: Data(), name: "Raquel", localizable: true, notifications: true, theme: .themeFour, backgroundActivity: true, streak: 12)
//
//        store.currentProfile = profile
//
//        #expect(store.currentProfile.profileID == profile.profileID)
//        #expect(store.currentProfile.streak == 12)
//    }
}
