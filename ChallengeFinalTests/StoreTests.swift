//
//  StoreTests.swift
//  ChallengeFinalTests
//
//  Created by Paulo Henrique Costa Alves on 19/10/26.
//

import Foundation
import Testing
import SwiftData
import SwiftUI
import UIKit
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
    
    @Test func testingDisplayRestoredChallengeStoresFieldsWithoutMarkingReady() {
        let (store, _) = createActivityStore()

        store.displayRestoredChallenge(title: "título", subtitle: "sub", description: "descrição")

        #expect(store.activityTitle == "título")
        #expect(store.activitySubtitle == "sub")
        #expect(store.activityDescription == "descrição")
        // Não é um sorteio novo: a View não deve animar a bola de novo.
        #expect(store.isChallengeReady == false)
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

    // MARK: ActivityStore (conquista)

    @Test func testingActivityStoreStartsWithoutAchievement() {
        let (store, _) = createActivityStore()

        #expect(store.achievementTitle == nil)
        #expect(store.achievementDescription == nil)
    }

    @Test func testingTransitionToSummaryStoresAchievementAndGoesToSummary() {
        let (store, coordinator) = createActivityStore()

        store.transitionToSummary(achievement: Achievement(title: "mestre offline", description: "você passou 1h offline"))

        #expect(store.achievementTitle == "mestre offline")
        #expect(store.achievementDescription == "você passou 1h offline")
        #expect(coordinator.step == .summary)
    }

    @Test func testingTransitionToSummaryReplacesPreviousAchievement() {
        let (store, _) = createActivityStore()
        store.transitionToSummary(achievement: Achievement(title: "mestre offline", description: "você passou 1h offline"))

        store.transitionToSummary(achievement: Achievement(title: "olhar atento", description: "você passou 5 min observando"))

        #expect(store.achievementTitle == "olhar atento")
        #expect(store.achievementDescription == "você passou 5 min observando")
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
        let walk = makeFeelingActivity(named: "Caminhada", humor: .pleasant)
        let read = makeFeelingActivity(named: "Leitura", humor: .veryPleasant)

        store.presentFeelingsLoaded(feelings: [.pleasant: [(walk, nil)], .veryPleasant: [(read, nil)]])

        #expect(store.feelings.count == 2)
        #expect(store.feelings[.pleasant]?.first?.activity === walk)
        #expect(store.feelings[.veryPleasant]?.first?.activity === read)
    }

    @Test func testingPresentFeelingsLoadedReplacesPreviousFeelings() {
        let store = FeelingsStore()
        store.presentFeelingsLoaded(feelings: [.pleasant: [(makeFeelingActivity(named: "Caminhada", humor: .pleasant), nil)]])

        store.presentFeelingsLoaded(feelings: [.veryPleasant: [(makeFeelingActivity(named: "Leitura", humor: .veryPleasant), nil)]])

        #expect(store.feelings[.pleasant] == nil)
        #expect(store.feelings[.veryPleasant]?.count == 1)
    }

    @Test func testingPresentFeelingsLoadedWithEmptyDictionaryClearsStore() {
        let store = FeelingsStore()
        store.presentFeelingsLoaded(feelings: [.pleasant: [(makeFeelingActivity(named: "Caminhada", humor: .pleasant), nil)]])

        store.presentFeelingsLoaded(feelings: [:])

        #expect(store.feelings.isEmpty)
    }

    @Test func testingPresentFeelingsLoadedKeepsImageNextToActivity() {
        let store = FeelingsStore()
        let walk = makeFeelingActivity(named: "Caminhada", humor: .pleasant)
        let image = Image(systemName: "photo")

        store.presentFeelingsLoaded(feelings: [.pleasant: [(walk, image), (makeFeelingActivity(named: "Leitura", humor: .pleasant), nil)]])

        #expect(store.feelings[.pleasant]?.first?.image != nil)
        #expect(store.feelings[.pleasant]?.last?.image == nil)
    }

    @Test func testingFeelingsStoreStartsWithDetailAndCameraClosed() {
        let store = FeelingsStore()

        #expect(store.presentDetail == false)
        #expect(store.selectedActivity == nil)
        #expect(store.selectedPhoto == nil)
        #expect(store.isCameraPresented == false)
        #expect(store.cameraFlashIcon == "bolt.slash")
        #expect(store.errorMessage == nil)
        #expect(store.storyImage == nil)
        #expect(store.shareItem == nil)
    }

    @Test func testingPresentActivityDetailsOpensDetail() {
        let store = FeelingsStore()
        let walk = makeFeelingActivity(named: "Caminhada", humor: .pleasant)

        store.presentActivityDetails(activity: walk, photo: Image(systemName: "photo"))

        #expect(store.presentDetail)
        #expect(store.selectedActivity === walk)
        #expect(store.selectedPhoto != nil)
    }

    @Test func testingReturnToFeelingsClosesDetail() {
        let store = FeelingsStore()
        store.presentActivityDetails(activity: makeFeelingActivity(named: "Caminhada", humor: .pleasant), photo: nil)

        store.returnToFeelings()

        #expect(store.presentDetail == false)
    }

    // A foto nova vale para o detalhe e para o card da mesma atividade na lista.
    @Test func testingPresentPhotoUpdatesSelectedPhotoAndMatchingListEntry() {
        let store = FeelingsStore()
        let walk = makeFeelingActivity(named: "Caminhada", humor: .pleasant)
        let read = makeFeelingActivity(named: "Leitura", humor: .veryPleasant)
        store.presentFeelingsLoaded(feelings: [.pleasant: [(walk, nil)], .veryPleasant: [(read, nil)]])
        store.presentActivityDetails(activity: walk, photo: nil)

        store.presentPhoto(Image(systemName: "photo"))

        #expect(store.selectedPhoto != nil)
        #expect(store.feelings[.pleasant]?.first?.image != nil)
        // As outras atividades não mudam.
        #expect(store.feelings[.veryPleasant]?.first?.image == nil)
    }

    @Test func testingPresentPhotoWithoutSelectedActivityOnlySetsSelectedPhoto() {
        let store = FeelingsStore()
        let walk = makeFeelingActivity(named: "Caminhada", humor: .pleasant)
        store.presentFeelingsLoaded(feelings: [.pleasant: [(walk, nil)]])

        store.presentPhoto(Image(systemName: "photo"))

        #expect(store.selectedPhoto != nil)
        #expect(store.feelings[.pleasant]?.first?.image == nil)
    }

    @Test func testingPresentDetailVisibilityKeepsSelectedActivity() {
        let store = FeelingsStore()
        let walk = makeFeelingActivity(named: "Caminhada", humor: .pleasant)
        store.presentActivityDetails(activity: walk, photo: nil)

        store.presentDetailVisibility(isVisible: false)

        #expect(store.presentDetail == false)
        #expect(store.selectedActivity === walk)

        store.presentDetailVisibility(isVisible: true)

        #expect(store.presentDetail)
    }

    // O alerta abre com mensagem e, ao fechar, limpa a mensagem.
    @Test func testingIsErrorPresentedFollowsMessage() {
        let store = FeelingsStore()
        #expect(store.isErrorPresented == false)

        store.presentError("Ops")
        #expect(store.isErrorPresented)

        store.isErrorPresented = false
        #expect(store.errorMessage == nil)
    }

    @Test func testingFeelingsStoreCameraState() {
        let store = FeelingsStore()

        store.presentCamera(isPresented: true)
        store.presentFlashIcon("bolt.fill")
        store.presentError("Ops")

        #expect(store.isCameraPresented)
        #expect(store.cameraFlashIcon == "bolt.fill")
        #expect(store.errorMessage == "Ops")

        store.presentCamera(isPresented: false)
        store.presentError(nil)

        #expect(store.isCameraPresented == false)
        #expect(store.errorMessage == nil)
    }

    @Test func testingFeelingsStoreShareState() {
        let store = FeelingsStore()
        let item = ShareItem(activityItems: [URL(fileURLWithPath: "/tmp/story.png")])

        store.presentStoryImage(UIImage())
        store.presentShareSheet(item)

        #expect(store.storyImage != nil)
        #expect(store.shareItem?.id == item.id)

        store.presentShareSheet(nil)

        #expect(store.shareItem == nil)
    }

    // MARK: - ChallengesStore

    @Test func testingChallengesStoreStartsEmptyAndClosed() {
        let store = ChallengesStore()

        #expect(store.challenges.isEmpty)
        #expect(store.selectedCategory == nil)
        #expect(store.emptyState == nil)
        #expect(store.archivedChallenges.isEmpty)
        #expect(store.archivedEmptyState == nil)
        #expect(store.isArchivedPresented == false)
        #expect(store.selectedChallenge == nil)
        #expect(store.selectedPhoto == nil)
        #expect(store.shareItem == nil)
        #expect(store.errorMessage == nil)
    }

    @Test func testingDisplayChallengesStoresListFilterAndEmptyState() {
        let store = ChallengesStore()
        let walk = makeFeelingActivity(named: "Caminhada", humor: .pleasant)

        store.displayChallenges([walk], selectedCategory: .physical, emptyState: nil)

        #expect(store.challenges.first === walk)
        #expect(store.selectedCategory == .physical)
        #expect(store.emptyState == nil)

        store.displayChallenges([], selectedCategory: nil, emptyState: .noResults)

        #expect(store.challenges.isEmpty)
        #expect(store.selectedCategory == nil)
        #expect(store.emptyState == .noResults)
    }

    @Test func testingDisplayArchivedChallengesAndSheet() {
        let store = ChallengesStore()
        let archived = makeFeelingActivity(named: "Arquivada", humor: .pleasant)

        store.displayArchivedChallenges([archived], emptyState: nil)
        store.displayArchivedSheet(isPresented: true)

        #expect(store.archivedChallenges.first === archived)
        #expect(store.archivedEmptyState == nil)
        #expect(store.isArchivedPresented)

        store.displayArchivedChallenges([], emptyState: .noArchived)
        store.displayArchivedSheet(isPresented: false)

        #expect(store.archivedChallenges.isEmpty)
        #expect(store.archivedEmptyState == .noArchived)
        #expect(store.isArchivedPresented == false)
    }

    @Test func testingDisplaySummaryOpensAndCloses() {
        let store = ChallengesStore()
        let walk = makeFeelingActivity(named: "Caminhada", humor: .pleasant)

        store.displaySummary(walk, photo: Image(systemName: "photo"))

        #expect(store.selectedChallenge === walk)
        #expect(store.selectedPhoto != nil)

        store.displaySummary(nil, photo: nil)

        #expect(store.selectedChallenge == nil)
        #expect(store.selectedPhoto == nil)
    }

    @Test func testingChallengesStoreShareAndErrorState() {
        let store = ChallengesStore()
        let item = ShareItem(activityItems: [URL(fileURLWithPath: "/tmp/story.png")])

        store.displayShareSheet(item)
        store.displayError("Ops")

        #expect(store.shareItem?.id == item.id)
        #expect(store.errorMessage == "Ops")

        store.displayShareSheet(nil)
        store.displayError(nil)

        #expect(store.shareItem == nil)
        #expect(store.errorMessage == nil)
    }

    // Cada estado vazio precisa de título e mensagem próprios (a View só mostra o que vem daqui).
    @Test func testingChallengesEmptyStatesHaveDistinctTexts() {
        let states: [ChallengesEmptyState] = [.noCompleted, .noResults, .noArchived]

        #expect(states.allSatisfy { !$0.title.isEmpty && !$0.message.isEmpty })
        #expect(Set(states.map(\.title)).count == states.count)
        #expect(Set(states.map(\.message)).count == states.count)
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
