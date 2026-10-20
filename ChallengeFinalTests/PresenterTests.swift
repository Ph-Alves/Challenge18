////
////  PresenterTests.swift
////  ChallengeFinalTests
////
////  Created by Paulo Henrique Costa Alves on 19/10/26.
////
//
//import Foundation
//import Testing
//@testable import ChallengeFinal
//
//// MARK: - Spies (test doubles for the Interactor protocols the Presenters talk to)
//
//final class HomeInteractorSpy: HomeInteractorProtocol {
//    private(set) var fetchGroupsCallCount = 0
//    func fetchGroups() {
//        fetchGroupsCallCount += 1
//    }
//}
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
//@Suite("Tests for all presenters in the project")
//@MainActor
//struct PresenterTests {
//
//    // MARK: - HomePresenter
//
//    @Test func testingFetchDataAsksInteractorOnlyOnce() async throws {
//        let interactorSpy = HomeInteractorSpy()
//        let store = HomeStore()
//        let presenter = HomePresenter(interactor: interactorSpy, store: store)
//
//        presenter.fetchData()
//        presenter.fetchData()
//
//        #expect(interactorSpy.fetchGroupsCallCount == 1)
//    }
//
//    @Test func testingPresentGroupsUpdatesStoreAndPresenter() async throws {
//        let interactorSpy = HomeInteractorSpy()
//        let store = HomeStore()
//        let presenter = HomePresenter(interactor: interactorSpy, store: store)
//        let group = Group(groupID: UUID(), type: .physical, context: "home")
//
//        presenter.presentGroups([group])
//
//        #expect(store.groups.count == 1)
//        #expect(presenter.groups.first?.groupID == group.groupID)
//    }
//
//    // MARK: - ActivitiesPresenter
//
//    @Test func testingActivitiesFetchDataDelegatesToInteractor() async throws {
//        let interactorSpy = ActivitiesInteractorSpy()
//        let store = ActivitiesStore()
//        let presenter = ActivitiesPresenter(interactor: interactorSpy, store: store)
//
//        presenter.fetchData()
//
//        #expect(interactorSpy.fetchHistoryCallCount == 1)
//    }
//
//    @Test func testingPresentHistoryUpdatesStoreLists() async throws {
//        let interactorSpy = ActivitiesInteractorSpy()
//        let store = ActivitiesStore()
//        let presenter = ActivitiesPresenter(interactor: interactorSpy, store: store)
//        let group = Group(groupID: UUID(), type: .cognitive, context: "home")
//        let accepted = Activity(activityID: UUID(), group: group, result: nil, name: "Done", description: "-", archived: true)
//        let recused = Activity(activityID: UUID(), group: group, result: nil, name: "Skipped", description: "-", archived: true)
//
//        presenter.presentHistory(accepted: [accepted], recused: [recused])
//
//        #expect(presenter.accepted.first?.activityID == accepted.activityID)
//        #expect(presenter.recused.first?.activityID == recused.activityID)
//        #expect(store.accepted.count == 1)
//        #expect(store.recused.count == 1)
//    }
//
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
//}
