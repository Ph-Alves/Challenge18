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
    @Environment(\.scenePhase) private var scenePhase

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
                    // O TabView aplica .fill automaticamente em SF Symbols; desligamos para respeitar base/fill.
                    .environment(\.symbolVariants, .none)
            }
            Tab(value: AppTab.challenges) {
                coordinator.challengesCoordinator.startChallengesFlow(context: context)
            } label: {
                Label("Challenges", systemImage: coordinator.selectedTab == .challenges ? designSystem.style.icons.tabBar.challenge.fill: designSystem.style.icons.tabBar.challenge.base)
            }
            Tab(value: AppTab.feelings) {
                coordinator.feelingsCoordinator.startFeelingsView(context: context)
            } label: {
                Label("Feelings", systemImage: coordinator.selectedTab == .feelings ? designSystem.style.icons.tabBar.feelings.fill: designSystem.style.icons.tabBar.feelings.base)
                    .environment(\.symbolVariants, .none)
            }
            Tab(value: AppTab.profile) {
                coordinator.profileCoordinator.startProfileView(context: context)
            } label: {
                Label("Profile", systemImage: coordinator.selectedTab == .profile ? designSystem.style.icons.tabBar.profile.fill: designSystem.style.icons.tabBar.profile.base)
                    .environment(\.symbolVariants, .none)
            }
        }
        .tint(.primary)
        // Ao abrir o app: aplica o tema salvo (sem esperar a aba de Perfil carregar) e
        // renova a janela de lembretes.
        .task {
            applySavedTheme()
            await refreshReminder()
        }
        // Renova a janela de lembretes sempre que o app volta a ficar ativo (voltou do segundo
        // plano, ou o usuário tocou na notificação). É isso que mantém os lembretes sempre à
        // frente: o iOS não roda código do app quando a notificação toca.
        .onChange(of: scenePhase) { _, phase in
            if phase == .active {
                Task { await refreshReminder() }
            }
        }
        
      
    }
    
    private func applySavedTheme() {
        guard let profile = try? context.fetch(FetchDescriptor<Profile>()).first,
              designSystem.currentTheme != profile.theme else { return }
        designSystem.currentTheme = profile.theme
    }
    
    /// Pede ao Service para deixar o lembrete diário no estado certo. É seguro chamar sempre
    /// (idempotente): com o toggle desligado só cancela; com ele ligado refaz a janela,
    /// pulando hoje se o usuário já concluiu um desafio.
    private func refreshReminder() async {
        await ReminderSchedulerService.make(context: context).refresh()
    }
}
