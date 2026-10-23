//
//  StoreTests.swift
//  ChallengeFinalTests
//
//  Created by Paulo Henrique Costa Alves on 19/10/26.
//

import Foundation
import Testing
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
//
//    // MARK: - ActivitiesStore
//
//    @Test func testingActivitiesStoreStartsEmpty() async throws {
//        let store = ActivitiesStore()
//
//        #expect(store.accepted.isEmpty)
//        #expect(store.recused.isEmpty)
//        #expect(store.currentActivity == nil)
//    }
//
//    @Test func testingActivitiesStoreHoldsCurrentActivity() async throws {
//        let store = ActivitiesStore()
//        let group = Group(groupID: UUID(), type: .social, context: "home")
//        let activity = Activity(activityID: UUID(), group: group, result: nil, name: "Draw", description: "-", archived: false)
//
//        store.currentActivity = activity
//
//        #expect(store.currentActivity?.activityID == activity.activityID)
//    }
//
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
