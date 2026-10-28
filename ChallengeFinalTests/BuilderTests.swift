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
