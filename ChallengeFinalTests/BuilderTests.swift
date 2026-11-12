//
//  BuilderTests.swift
//  ChallengeFinalTests
//
//  Created by Paulo Henrique Costa Alves on 19/10/26.
//

import Foundation
import Testing
import SwiftData
@testable import ChallengeFinal

@MainActor
@Suite("Tests for all builders in the project")
struct BuilderTests {
    
    // MARK: - Auxiliadores
    let modelContainer: ModelContainer = {
        let schema = Schema([Activity.self, ActivityResult.self, Profile.self])
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        return try! ModelContainer(for: schema, configurations: config)
    }()
    
    private func makeHomeCoordinator() -> HomeCoordinator {
        return HomeCoordinator()
    }
//
//    // MARK: - Testes
    
    @Test func testingHomeBuilding() async {
        let coordinator = makeHomeCoordinator()
        let home: HomeView? = coordinator.startHomeFlow(context: modelContainer.mainContext)
        
        #expect(home != nil)
    }
    
    @Test func testingCheckHomeCachedView() async {
        let coordinator = makeHomeCoordinator()
        _ = coordinator.startHomeFlow(context: modelContainer.mainContext)
        
        #expect(coordinator.cached != nil)
    }
    
    @Test func testingActivityBuilding() async {
        let coordinator = ActivityCoordinator(selectedCategory: .physical, onFinish: {})
        let view = coordinator.startActivityView(context: modelContainer.mainContext)
        
        #expect(coordinator.cached != nil)
        _ = view
    }
    
    @Test func testingActivityViewIsCachedAcrossCalls() async {
        let coordinator = ActivityCoordinator(selectedCategory: .social, onFinish: {})
        let first = coordinator.startActivityView(context: modelContainer.mainContext)
        let second = coordinator.startActivityView(context: modelContainer.mainContext)
        
        // Mesma instância de store = a view não foi reconstruída.
        #expect(first.store === second.store)
    }
    
    @Test func testingStartActivityFlowChangesHomeStep() async {
        let coordinator = makeHomeCoordinator()
        
        coordinator.startActivityFlow(category: .cognitive)
        
        if case .activity = coordinator.step {} else {
            Issue.record("Esperava o step .activity depois de iniciar o fluxo")
        }
    }

    // MARK: - Home reabre a Activity depois dos Ajustes

    private func makeIsolatedDefaults() -> UserDefaults {
        let name = "BuilderTests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: name)!
        defaults.removePersistentDomain(forName: name)
        return defaults
    }

    private func saveSnapshot(in defaults: UserDefaults, savedAt: Date = Date()) throws {
        let snapshot = TemporaryData(step: .photo, category: .sensorial, activityID: UUID(), resultID: UUID(),
                                     title: "t", subtitle: "s", description: "d",
                                     achievementTitle: "a", achievementDescription: "b", savedAt: savedAt)
        defaults.set(try JSONEncoder().encode(snapshot), forKey: TemporaryData.key)
    }

    @Test func testingHomeCoordinatorStartsInActivityWhenThereIsASnapshot() throws {
        let defaults = makeIsolatedDefaults()
        try saveSnapshot(in: defaults)

        let coordinator = HomeCoordinator(defaults: defaults)

        guard case .activity(let flow) = coordinator.step else {
            Issue.record("Esperava começar no step .activity com um snapshot válido")
            return
        }
        // O fluxo já nasce no step salvo, sem passar pelo sorteio.
        #expect(flow.step == .photo)
        // A Home só espia: quem consome o snapshot é o `restoreData()` do Interactor.
        #expect(defaults.data(forKey: TemporaryData.key) != nil)
    }

    @Test func testingActivityCoordinatorStartsInDrawByDefault() {
        let coordinator = ActivityCoordinator(selectedCategory: .physical, onFinish: {})

        #expect(coordinator.step == .draw)
    }

    @Test(arguments: [ActivityStep.challenge, .inProgress, .mood, .photo, .summary])
    func testingActivityCoordinatorStartsInTheGivenStep(step: ActivityStep) {
        let coordinator = ActivityCoordinator(selectedCategory: .physical, initialStep: step, onFinish: {})

        #expect(coordinator.step == step)
    }

    @Test func testingStartActivityFlowWithoutStepStartsInDraw() {
        let coordinator = makeHomeCoordinator()

        coordinator.startActivityFlow(category: .cognitive)

        guard case .activity(let flow) = coordinator.step else {
            Issue.record("Esperava o step .activity depois de iniciar o fluxo")
            return
        }
        #expect(flow.step == .draw)
    }

    @Test func testingHomeCoordinatorStartsInHomeWithoutASnapshot() {
        let coordinator = HomeCoordinator(defaults: makeIsolatedDefaults())

        if case .home = coordinator.step {} else {
            Issue.record("Esperava começar no step .home sem snapshot")
        }
    }

    @Test func testingHomeCoordinatorIgnoresAnExpiredSnapshot() throws {
        let defaults = makeIsolatedDefaults()
        try saveSnapshot(in: defaults, savedAt: Date().addingTimeInterval(-TemporaryData.lifetime - 1))

        let coordinator = HomeCoordinator(defaults: defaults)

        if case .home = coordinator.step {} else {
            Issue.record("Esperava começar no step .home com o snapshot expirado")
        }
    }


    // MARK: - Feelings

    @Test func testingFeelingsCoordinatorStartsWithoutCachedView() {
        let coordinator = FeelingsCoordinator()
        
        #expect(coordinator.cached == nil)
    }
    
    @Test func testingFeelingsBuilding() async {
        let coordinator = FeelingsCoordinator()
        _ = coordinator.startFeelingsView(context: modelContainer.mainContext)
        
        #expect(coordinator.cached != nil)
    }
    
    @Test func testingFeelingsViewIsCachedAcrossCalls() async {
        let coordinator = FeelingsCoordinator()
        let first = coordinator.startFeelingsView(context: modelContainer.mainContext)
        let second = coordinator.startFeelingsView(context: modelContainer.mainContext)
        
        // Mesma instância de store = a view não foi reconstruída.
        #expect(first.store === second.store)
    }
    
    @Test func testingFeelingsCoordinatorReusesInjectedView() async {
        let context = modelContainer.mainContext
        let view = FeelingsBuilder.build(context: context)
        let coordinator = FeelingsCoordinator()
        coordinator.cached = view
        
        let started = coordinator.startFeelingsView(context: context)
        
        #expect(started.store === view.store)
    }
    
    // O Builder liga Interactor -> Presenter -> Store: carregar pelo interactor da view enche a store da mesma view.
    @Test func testingFeelingsBuilderWiresInteractorToStore() throws {
        let context = modelContainer.mainContext
        let result = ActivityResult(time: 5, humor: .pleasant)
        let activity = Activity(category: .physical, result: result, name: "Caminhada", description: "-", archived: false)
        try GenericRepository<Activity>(context: context).add(activity)
        let view = FeelingsBuilder.build(context: context)
        
        view.interactor.loadFeelings()
        
        #expect(view.store.feelings[.pleasant]?.count == 1)
        #expect(view.store.feelings[.pleasant]?.first?.activity === activity)
    }
    
    // MARK: - Challenges

    @Test func testingChallengesCoordinatorStartsWithoutCachedView() {
        let coordinator = ChallengesCoordinator()

        #expect(coordinator.cached == nil)
    }

    @Test func testingChallengesBuilding() {
        let coordinator = ChallengesCoordinator()
        _ = coordinator.startChallengesFlow(context: modelContainer.mainContext)

        #expect(coordinator.cached != nil)
    }

    @Test func testingChallengesViewIsCachedAcrossCalls() {
        let coordinator = ChallengesCoordinator()
        let first = coordinator.startChallengesFlow(context: modelContainer.mainContext)
        let second = coordinator.startChallengesFlow(context: modelContainer.mainContext)

        // Mesma instância de store = a view não foi reconstruída.
        #expect(first.store === second.store)
    }

    @Test func testingChallengesCoordinatorReusesInjectedView() {
        let context = modelContainer.mainContext
        let view = ChallengesBuilder.build(context: context)
        let coordinator = ChallengesCoordinator(cached: view)

        let started = coordinator.startChallengesFlow(context: context)

        #expect(started.store === view.store)
    }

    // O Builder liga Interactor -> Presenter -> Store: carregar pelo interactor da view enche a store da mesma view.
    @Test func testingChallengesBuilderWiresInteractorToStore() throws {
        let context = modelContainer.mainContext
        let repository = GenericRepository<Activity>(context: context)
        let completed = Activity(category: .physical, result: ActivityResult(time: 5, humor: .pleasant),
                                 name: "Caminhada", description: "-", archived: false)
        let archived = Activity(category: .social, result: nil, name: "Arquivada", description: "-", archived: true)
        try repository.add(completed)
        try repository.add(archived)
        let view = ChallengesBuilder.build(context: context)

        view.interactor.loadChallenges()

        #expect(view.store.challenges.count == 1)
        #expect(view.store.challenges.first === completed)
        #expect(view.store.archivedChallenges.first === archived)
    }

    // MARK: - ActivityStep (botão de navegação e alerta de saída)

    // Cada par é (step, botão esperado no canto superior esquerdo).
    @Test(arguments: [
        (ActivityStep.draw, ActivityNavigationButton.back),
        (.challenge, .close),
        (.inProgress, .close),
        (.mood, .close),
        (.photo, .back),
        (.summary, .back)
    ])
    func testingNavigationButtonForEachStep(step: ActivityStep, expected: ActivityNavigationButton) {
        #expect(step.navigationButton == expected)
    }

    // Só o X abre o alerta "deseja sair do desafio?". Nele, `.challenge` e `.mood` explicam o que acontece ao sair;
    // `.inProgress` também tem X, mas mostra só o título e os botões, sem mensagem.
    @Test(arguments: [
        (ActivityStep.draw, false),
        (.challenge, true),
        (.inProgress, false),
        (.mood, true),
        (.photo, false),
        (.summary, false)
    ])
    func testingExitMessageForEachStep(step: ActivityStep, expectsMessage: Bool) {
        let hasMessage = step.exitMessage?.isEmpty == false

        #expect(hasMessage == expectsMessage)
    }

    // Todo step sem X não abre alerta, então não pode ter mensagem de saída.
    @Test(arguments: [ActivityStep.draw, .challenge, .inProgress, .mood, .photo, .summary])
    func testingStepsWithoutCloseButtonHaveNoExitMessage(step: ActivityStep) {
        guard step.navigationButton != .close else { return }

        #expect(step.exitMessage == nil)
    }

//    @Test func testingProfileBuilding() async throws {
//        let builder: ProfileBuilderProtocol = createProfileBuilder()
//        let viewConfig = builder.buildConfig()
//        
//        #expect(viewConfig == ProfileConfig())
//    }
//    
//    @Test func testingCheckProfileCachedView() async throws {
//        let builder: ProfileBuilderProtocol = createProfileBuilder()
//        _ = builder.build()
//        
//        #expect(builder.cachedView != nil)
//    }
}
