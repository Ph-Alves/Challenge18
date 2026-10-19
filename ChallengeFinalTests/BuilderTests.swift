////
////  BuilderTests.swift
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
//@Suite("Tests for all builders in the project")
//struct BuilderTests {
//    
//    // MARK: - Auxiliadores
//    let modelContainer: ModelContainer = {
//        let schema = Schema([Activity.self, Profile.self, ActivityResult.self, ActivityGroup.self])
//        let config = ModelConfiguration(isStoredInMemoryOnly: true)
//        return try! ModelContainer(for: schema, configurations: config)
//    }()
//    
//    private func createActivityBuilder() -> ActivityBuilderProtocol {
//        return ActivitiesBuilder(modelContainer.mainContext)
//    }
//    
//    private func createHomeBuilder() -> ActivityBuilderProtocol {
//        return HomeBuilder(modelContainer.mainContext)
//    }
//    
//    private func createProfileBuilder() -> ActivityBuilderProtocol {
//        return ProfileBuilder(modelContainer.mainContext)
//    }
//    
//    // MARK: - Testes
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
//    @Test func testingHomeBuilding() async throws {
//        let builder: HomeBuilderProtocol = createHomeBuilder()
//        let viewConfig = builder.buildConfig()
//        
//        #expect(viewConfig == HomeConfig())
//    }
//    
//    @Test func testingCheckHomeCachedView() async throws {
//        let builder: HomeBuilderProtocol = createHomeBuilder()
//        _ = builder.build()
//        
//        #expect(builder.cachedView != nil)
//    }
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
//}
