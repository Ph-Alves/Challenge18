////
////  InteractorTests.swift
////  ChallengeFinalTests
////
////  Created by Paulo Henrique Costa Alves on 19/10/26.
////
//
//import Foundation
//import Testing
//import SwiftData
//@testable import ChallengeFinal
//
//// MARK: - Spies (test doubles for the Presenter protocols the Interactors talk to)
//
//final class HomePresenterSpy: HomePresenterProtocol {
//    private(set) var presentedGroups: [Group]?
//    func presentGroups(_ groups: [Group]) {
//        presentedGroups = groups
//    }
//}
//
//final class ActivitiesPresenterSpy: ActivitiesPresenterProtocol {
//    private(set) var presentedActivity: Activity?
//    private(set) var presentedHistory: (accepted: [Activity], recused: [Activity])?
//    func presentActivity(_ activity: Activity?) {
//        presentedActivity = activity
//    }
//    func presentHistory(accepted: [Activity], recused: [Activity]) {
//        presentedHistory = (accepted, recused)
//    }
//}
//
//final class ProfilePresenterSpy: ProfilePresenterProtocol {
//    private(set) var presentedProfile: Profile?
//    func presentProfile(_ profile: Profile) {
//        presentedProfile = profile
//    }
//}
//
//@Suite("Tests for all interactors in the project")
//@MainActor
//struct InteractorTests {
//
//    // MARK: - Auxiliadores
//    let modelContainer: ModelContainer = {
//        let schema = Schema([Group.self, Activity.self, Results.self, Profile.self])
//        let config = ModelConfiguration(isStoredInMemoryOnly: true)
//        return try! ModelContainer(for: schema, configurations: config)
//    }()
//
//    private func makeGroupRepository() -> GenericRepository<Group> {
//        GenericRepository(context: modelContainer.mainContext)
//    }
//
//    private func makeActivityRepository() -> GenericRepository<Activity> {
//        GenericRepository(context: modelContainer.mainContext)
//    }
//
//    private func makeProfileRepository() -> GenericRepository<Profile> {
//        GenericRepository(context: modelContainer.mainContext)
//    }
//
//    // MARK: - HomeInteractor (RF01 - visualizar grupos de atividade)
//
//    @Test func testingFetchGroupsPresentsEveryGroupSavedInRepository() async throws {
//        let repository = makeGroupRepository()
//        let physical = Group(groupID: UUID(), type: .physical, context: "home")
//        let cognitive = Group(groupID: UUID(), type: .cognitive, context: "home")
//        repository.insert(physical)
//        repository.insert(cognitive)
//        repository.save()
//
//        let presenterSpy = HomePresenterSpy()
//        let interactor = HomeInteractor(repository: repository, presenter: presenterSpy)
//
//        interactor.fetchGroups()
//
//        #expect(presenterSpy.presentedGroups?.count == 2)
//        #expect(presenterSpy.presentedGroups?.contains { $0.groupID == physical.groupID } == true)
//        #expect(presenterSpy.presentedGroups?.contains { $0.groupID == cognitive.groupID } == true)
//    }
//
//    // MARK: - ActivitiesInteractor (RF03/RF06 - gerar e trocar atividade)
//
//    @Test func testingGenerateActivitySkipsArchivedAndOtherGroups() async throws {
//        let repository = makeActivityRepository()
//        let groupA = Group(groupID: UUID(), type: .physical, context: "home")
//        let groupB = Group(groupID: UUID(), type: .social, context: "home")
//        let archived = Activity(activityID: UUID(), group: groupA, result: nil, name: "Archived", description: "-", archived: true)
//        let available = Activity(activityID: UUID(), group: groupA, result: nil, name: "Available", description: "-", archived: false)
//        let otherGroup = Activity(activityID: UUID(), group: groupB, result: nil, name: "Other", description: "-", archived: false)
//        [archived, available, otherGroup].forEach { repository.insert($0) }
//        repository.save()
//
//        let presenterSpy = ActivitiesPresenterSpy()
//        let interactor = ActivitiesInteractor(repository: repository, presenter: presenterSpy)
//
//        interactor.generateActivity(for: groupA)
//
//        #expect(presenterSpy.presentedActivity?.activityID == available.activityID)
//    }
//
//    // MARK: - ActivitiesInteractor (RF12/RN14 - concluir atividade)
//
//    @Test func testingConcludeActivityArchivesAndStoresResult() async throws {
//        let repository = makeActivityRepository()
//        let group = Group(groupID: UUID(), type: .cognitive, context: "home")
//        let activity = Activity(activityID: UUID(), group: group, result: nil, name: "Puzzle", description: "-", archived: false)
//        repository.insert(activity)
//        repository.save()
//
//        let presenterSpy = ActivitiesPresenterSpy()
//        let interactor = ActivitiesInteractor(repository: repository, presenter: presenterSpy)
//        let result = Results(resultID: UUID(), photo: Data(), time: 180, humor: .calm)
//
//        interactor.concludeActivity(activity, result: result)
//
//        #expect(activity.archived == true)
//        #expect(activity.result?.resultID == result.resultID)
//        #expect(presenterSpy.presentedHistory?.accepted.contains { $0.activityID == activity.activityID } == true)
//    }
//
//    // MARK: - ActivitiesInteractor (RF07/RN10 - excluir permanentemente)
//
//    @Test func testingRefuseActivityPermanentlyArchivesWithoutResult() async throws {
//        let repository = makeActivityRepository()
//        let group = Group(groupID: UUID(), type: .sensorial, context: "home")
//        let activity = Activity(activityID: UUID(), group: group, result: nil, name: "Smell test", description: "-", archived: false)
//        repository.insert(activity)
//        repository.save()
//
//        let presenterSpy = ActivitiesPresenterSpy()
//        let interactor = ActivitiesInteractor(repository: repository, presenter: presenterSpy)
//
//        interactor.refuseActivityPermanently(activity)
//
//        #expect(activity.archived == true)
//        #expect(activity.result == nil)
//        #expect(presenterSpy.presentedHistory?.recused.contains { $0.activityID == activity.activityID } == true)
//    }
//
//    // MARK: - ActivitiesInteractor (RF08/RN09 - recusar temporariamente)
//
//    @Test func testingRefuseActivityTemporarilyDoesNotArchive() async throws {
//        let repository = makeActivityRepository()
//        let group = Group(groupID: UUID(), type: .social, context: "home")
//        let activity = Activity(activityID: UUID(), group: group, result: nil, name: "Chat", description: "-", archived: false)
//        repository.insert(activity)
//        repository.save()
//
//        let presenterSpy = ActivitiesPresenterSpy()
//        let interactor = ActivitiesInteractor(repository: repository, presenter: presenterSpy)
//
//        interactor.refuseActivityTemporarily(activity)
//
//        #expect(activity.archived == false)
//        #expect(presenterSpy.presentedHistory == nil)
//    }
//
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
//}
