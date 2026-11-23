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
    @Environment(DesignSystem.self) private var designSystem
    @Bindable var coordinator: AppCoordinator //bindlabe porque alem de ler o dado, ela também escreve.

    var body: some View {
        TabView(selection: $coordinator.selectedTab) {
            Tab(value: AppTab.home) {
                switch coordinator.homeCoordinator.step {
                case .home:
                    coordinator.homeCoordinator.startHomeFlow(context: context)
                case .activity(let flow):
                    flow.startActivityView(context: context).toolbarVisibility(.hidden, for: .tabBar)
                }
            } label: {
                Label("Home", systemImage: coordinator.selectedTab == .home ? designSystem.style.icons.tabBar.home.fill: designSystem.style.icons.tabBar.home.base)
            }
            Tab(value: AppTab.challenges) {
                coordinator.challengesCoordinator.startChallengesFlow(context: context)
            } label: {
                Label("Challenges", image: coordinator.selectedTab == .challenges ? designSystem.style.icons.tabBar.challenge.fill: designSystem.style.icons.tabBar.challenge.base)
            }
            Tab(value: AppTab.feelings) {
                coordinator.feelingsCoordinator.startFeelingsView(context: context)
            } label: {
                Label("Feelings", systemImage: coordinator.selectedTab == .feelings ? designSystem.style.icons.tabBar.feelings.fill: designSystem.style.icons.tabBar.feelings.base)
            }
            Tab(value: AppTab.profile) {
                coordinator.profileCoordinator.startProfileView(context: context)
            } label: {
                Label("Profile", systemImage: coordinator.selectedTab == .profile ? designSystem.style.icons.tabBar.profile.fill: designSystem.style.icons.tabBar.profile.base)
            }
        }
        .tint(.primary)
        // Aplica o tema salvo assim que o app abre, sem esperar a aba de Perfil carregar.
        .task { applySavedTheme() }
    }
    
    private func applySavedTheme() {
        guard let profile = try? context.fetch(FetchDescriptor<Profile>()).first,
              designSystem.currentTheme != profile.theme else { return }
        designSystem.currentTheme = profile.theme
    }
}
