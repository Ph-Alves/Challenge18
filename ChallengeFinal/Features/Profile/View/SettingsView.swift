//
//  SettingsView.swift
//  ChallengeFinal
//
//  Created by Raquel Souza on 16/11/26.
//

import SwiftUI

/// Sheet de configurações
/// Recebe só dados e closures; cada toggle avisa o Interactor, que decide se vale (permissões).
struct SettingsView: View {
    @Environment(DesignSystem.self) private var designSystem

    let localizable: Bool
    let notifications: Bool
    let backgroundActivity: Bool
    let closeAction: () -> Void
    let localizableAction: (Bool) -> Void
    let notificationsAction: (Bool) -> Void
    let backgroundAction: (Bool) -> Void

    private var typography: Typography { designSystem.style.typography }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Text("configurações")
                        .font(typography.title1)
                        .listRowBackground(Color.clear)
                        .listRowInsets(EdgeInsets(top: 4, leading: 10, bottom: 0, trailing: 10))
                }

                settingsSection(
                    title: "sua localização",
                    description: "compartilhe sua localização e descubra desafios feitos para onde você está!",
                    toggleLabel: "compartilhar localização",
                    isOn: binding(localizable, localizableAction)
                )

                settingsSection(
                    title: "notificações",
                    description: "ative as notificações, seja lembrado e receba desafios personalizados para onde estiver :)",
                    toggleLabel: "ativar notificações",
                    isOn: binding(notifications, notificationsAction)
                )

                settingsSection(
                    title: "atividade em segundo plano",
                    description: "o segundo plano permite que o timer dos desafios continuem rodando mesmo com o app fechado.",
                    toggleLabel: "ativar segundo plano",
                    isOn: binding(backgroundActivity, backgroundAction)
                )
            }
            .listSectionSpacing(16)
            .scrollContentBackground(.hidden)    // tira o cinza padrão da tela
            .background(designSystem.style.colors.backgroundPrimary)
            .foregroundStyle(designSystem.style.colors.textPrimary)
            .navigationTitle("configurações")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(role: .close, action: closeAction)
                }
            }
        }
    }

    // MARK: - Card (Section nativa)

    /// Uma Section = um card: linha de texto + divisor automático + linha do toggle.
    private func settingsSection(title: String, description: String,
                                 toggleLabel: String, isOn: Binding<Bool>) -> some View {
        Section {
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(typography.subtitle2)
                Text(description)
                    .font(typography.text2)
            }
            .padding(.vertical, 4)

            Toggle(toggleLabel, isOn: isOn)
                .font(typography.text2)
                .tint(.green)
        }
        .listRowBackground(Color(.systemGray6))
    }

    /// O valor vem da Store (via Presenter); a mudança vai para o Interactor.
    private func binding(_ value: Bool, _ action: @escaping (Bool) -> Void) -> Binding<Bool> {
        Binding(get: { value }, set: { action($0) })
    }
}

#Preview {
    SettingsView(localizable: true, notifications: true, backgroundActivity: true,
                 closeAction: {}, localizableAction: { _ in }, notificationsAction: { _ in }, backgroundAction: { _ in })
        .environment(DesignSystem.shared)
}
