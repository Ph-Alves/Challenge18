//
//  RootView.swift
//  ChallengeFinal
//
//  Created by Raquel Souza on 19/10/26.
//

import SwiftUI
import SwiftData

struct RootView: View {
    @Environment(\.modelContext) private var context
    @Bindable var coordinator: AppCoordinator //bindlabe porque alem de ler o dado, ela também escreve.

    var body: some View {
        TabView(selection: $coordinator.selectedTab) {
            Tab("Home", systemImage: "diamond.fill", value: AppTab.home) {
                switch coordinator.homeCoordinator.step {
                case .home:
                    coordinator.homeCoordinator.startHomeFlow(context: context)
                case .activity(let flow):
                    flow.startActivityView(context: context)
                }
            }
            Tab("Challenges", systemImage: "circle.fill", value: AppTab.challenges) {
                // feature ainda não existe
            }
            Tab("Feelings", systemImage: "triangle.fill", value: AppTab.feelings) {
                // feature ainda não existe
            }
            Tab("Profile", systemImage: "seal.fill", value: AppTab.profile) {
                // feature ainda não existe
            }
        }
    }
}
