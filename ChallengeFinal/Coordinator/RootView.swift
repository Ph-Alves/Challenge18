//
//  Untitled.swift
//  ChallengeFinal
//
//  Created by Raquel Souza on 19/10/26.
//

import SwiftUI

struct RootView: View {
    @Bindable var coordinator: AppCoordinator //bindlabe porque alem de ler o dado, ela também escreve.

    var body: some View {
        TabView(selection: $coordinator.selectedTab) {
            Tab("Home", systemImage: "diamond.fill", value: AppTab.home) {
                HomeView(coordinator: coordinator.homeCoordinator) //aqui eu uso coordinator.homeCoordinator pois vou usar o mesmo objeto criado apenas uma vez no my app (que é a var que estamos "bindlando"
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
