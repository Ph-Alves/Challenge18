//
//  ChallengeFinalWatchApp.swift
//  ChallengeFinalWatch Watch App
//
//  Created by Paulo Henrique Costa Alves on 19/11/26.
//

import SwiftUI

@main
struct ChallengeFinalWatch_Watch_AppApp: App {
    /// Vive enquanto o app vive: guarda o step atual e a view inicial em cache.
    @State private var coordinator = WatchCoordinator()

    var body: some Scene {
        WindowGroup {
            coordinator.startHomeView()
        }
    }
}
