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
                tabLabel(.home)
            }
            Tab(value: AppTab.challenges) {
                coordinator.challengesCoordinator.startChallengesFlow(context: context)
            } label: {
                tabLabel(.challenges)
            }
            Tab(value: AppTab.feelings) {
                coordinator.feelingsCoordinator.startFeelingsView(context: context)
            } label: {
                tabLabel(.feelings)
            }
            Tab(value: AppTab.profile) {
                coordinator.profileCoordinator.startProfileView(context: context)
            } label: {
                tabLabel(.profile)
            }
        }
        .tint(.primary)
        // Aplica o tema salvo assim que o app abre, sem esperar a aba de Perfil carregar.
        .task { applySavedTheme() }
    }

    /// Label de uma aba: troca base/fill conforme a seleção, venha o ícone do SF Symbols ou do Assets (Challenges muda com o tema).
    private func tabLabel(_ tab: AppTab) -> some View {
        Label {
            Text(tab.title)
        } icon: {
            tab.icon(for: designSystem.style).image(isSelected: coordinator.selectedTab == tab)
        }
        // O TabView aplica .fill automaticamente em SF Symbols; desligamos para respeitar base/fill.
        .environment(\.symbolVariants, .none)
    }
    
    private func applySavedTheme() {
        guard let profile = try? context.fetch(FetchDescriptor<Profile>()).first,
              designSystem.currentTheme != profile.theme else { return }
        designSystem.currentTheme = profile.theme
    }
}
