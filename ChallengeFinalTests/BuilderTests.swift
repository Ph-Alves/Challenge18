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
        let home: HomeView? = coordinator.startHome(context: modelContainer.mainContext)
        
        #expect(home != nil)
    }
    
    @Test func testingCheckHomeCachedView() async {
        let coordinator = makeHomeCoordinator()
        _ = coordinator.startHome(context: modelContainer.mainContext)
        
        #expect(coordinator.cachedHomeView != nil)
    }
//    @Test func testingActivitiesBuilding() async throws {
//        let builder: ActivitiesBuilderProtocol = createActivityBuilder()
//        let viewConfig = builder.buildConfig()
//        
//        #expect(viewConfig == ActivitiesConfig())
//    }
//    
//    @Test func testingCheckActivityCachedView() async throws {
//        let builder: ActivitiesBuilderProtocol = createActivityBuilder()
//        _ = builder.build()
//        
//        #expect(builder.cachedView != nil)
//    }
//
//    
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
