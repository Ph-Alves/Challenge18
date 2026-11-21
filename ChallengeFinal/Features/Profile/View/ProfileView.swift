//
//  ProfileView.swift
//  ChallengeFinal
//
//  Created by Raquel Souza on 16/10/26.
//

import SwiftUI
import PhotosUI

/// Tela de Perfil: cabeçalho (foto, nome e streak) + seção de temas.
/// Lápis = editar nome/foto. Engrenagem = sheet de configurações.
/// Só lê da Store e repassa as ações ao Interactor.
struct ProfileView: View {

    // MARK: - Variables

    @Environment(DesignSystem.self) private var designSystem
    @Environment(\.openURL) private var openURL

    let interactor: ProfileInteractorProtocol
    @State var store: ProfileStore

    /// Item escolhido no PhotosPicker (vira Data no Interactor).
    @State private var photoItem: PhotosPickerItem?
    @FocusState private var isNameFocused: Bool

    // MARK: - Body

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 48) {
                ProfileHeaderView(
                    name: store.name,
                    userPhoto: store.userPhoto,
                    streakText: store.streakText,
                    levelTitle: store.levelTitle,
                    levelSubtitle: store.levelSubtitle,
                    isEditing: store.isEditing,
                    draftName: $store.draftName,
                    photoItem: $photoItem,
                    isNameFocused: $isNameFocused,
                    editAction: toggleEditing,
                    settingsAction: interactor.openSettings
                )

                themesSection
                    .padding(.horizontal, 30)
            }
            .padding(.bottom, 32)
        }
        .scrollIndicators(.hidden)
        .ignoresSafeArea(edges: .top)
        .background(designSystem.style.colors.backgroundPrimary)
        .onAppear(perform: interactor.fetchProfile)
        .onChange(of: photoItem) { _, item in
            guard let item else { return }
            interactor.didSelectPhoto(item)
            photoItem = nil
        }
        .sheet(isPresented: $store.isSettingsPresented) {
            SettingsView(
                localizable: store.localizable,
                notifications: store.notifications,
                backgroundActivity: store.backgroundActivity,
                closeAction: interactor.closeSettings,
                localizableAction: interactor.updateLocalizable,
                notificationsAction: interactor.updateNotifications,
                backgroundAction: interactor.updateBackgroundActivity
            )
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
            // Com o sheet aberto, os alertas precisam ser dele (permissões vêm daqui).
            .alert("Ops!", isPresented: isPermissionAlertPresented) { permissionButtons } message: {
                Text(store.permissionAlertMessage ?? "")
            }
            .alert("Ops!", isPresented: isErrorAlertPresented) { errorButton } message: {
                Text(store.errorMessage ?? "")
            }
        }
        // Erros com o sheet fechado (ex.: foto que não carregou).
        .alert("Ops!", isPresented: isErrorAlertOutsideSheet) { errorButton } message: {
            Text(store.errorMessage ?? "")
        }
    }

    // MARK: - Seção de temas

    private var themesSection: some View {
        VStack(alignment: .leading, spacing: 24) {
            VStack(alignment: .leading, spacing: 4) {
                Text("temas")
                    .font(designSystem.style.typography.title1)
                Text("escolha um tema e deixe o app a sua cara")
                    .font(designSystem.style.typography.text2)
            }

            HStack(spacing: 26) {
                ForEach(store.themes, id: \.self) { theme in
                    ThemeCard(theme: theme, isSelected: theme == store.currentTheme) {
                        interactor.updateTheme(theme)
                    }
                }
            }
            .frame(maxWidth: .infinity)
        }
        .foregroundStyle(designSystem.style.colors.textPrimary)
    }

    // MARK: - Alertas

    /// Permissão negada: leva aos Ajustes do iPhone.
    @ViewBuilder
    private var permissionButtons: some View {
        Button("abrir ajustes") {
            if let url = URL(string: UIApplication.openSettingsURLString) {
                openURL(url)
            }
            interactor.dismissAlerts()
        }
        Button("Agora não", role: .cancel) { interactor.dismissAlerts() }
    }

    /// Erro técnico: só fecha.
    private var errorButton: some View {
        Button("OK", role: .cancel) { interactor.dismissAlerts() }
    }

    // O `.alert` precisa de um Binding<Bool>, mas a View só LÊ a Store.
    // Então o "get" lê a Store, e o "set" (quando o usuário fecha o alerta)
    // avisa o Interactor, que pede ao Presenter para limpar a mensagem.

    private var isPermissionAlertPresented: Binding<Bool> {
        Binding(
            get: { store.permissionAlertMessage != nil },
            set: { isPresented in
                if !isPresented { interactor.dismissAlerts() }
            }
        )
    }

    private var isErrorAlertPresented: Binding<Bool> {
        Binding(
            get: { store.errorMessage != nil },
            set: { isPresented in
                if !isPresented { interactor.dismissAlerts() }
            }
        )
    }

    /// Uma view só apresenta uma coisa por vez: com o sheet aberto, o alerta é dele.
    private var isErrorAlertOutsideSheet: Binding<Bool> {
        Binding(
            get: { store.errorMessage != nil && !store.isSettingsPresented },
            set: { isPresented in
                if !isPresented { interactor.dismissAlerts() }
            }
        )
    }

    // MARK: - Ações

    /// Lápis: entra no modo edição; no modo edição vira "check" e salva.
    private func toggleEditing() {
        if store.isEditing {
            isNameFocused = false
            interactor.saveEditing(name: store.draftName)
        } else {
            interactor.startEditing()
            isNameFocused = true
        }
    }
}

// MARK: - Stub pro preview

private final class ProfileInteractorStub: ProfileInteractorProtocol {
    func fetchProfile() {}
    func startEditing() {}
    func saveEditing(name: String) {}
    func didSelectPhoto(_ item: PhotosPickerItem) {}
    func updateTheme(_ theme: Theme) {}
    func openSettings() {}
    func closeSettings() {}
    func updateLocalizable(_ isOn: Bool) {}
    func updateNotifications(_ isOn: Bool) {}
    func updateBackgroundActivity(_ isOn: Bool) {}
    func dismissAlerts() {}
}

extension ProfileStore {
    static var preview: ProfileStore {
        let store = ProfileStore()
        store.displayProfile(name: "nome", userPhoto: nil)
        store.displayStreak(streakText: "0 dias", levelTitle: "começando :)", levelSubtitle: "o primeiro passo você já deu, agora falta se desafiar!")
        store.displayTheme(.sober)
        return store
    }
}

// MARK: - Preview
#Preview {
    ProfileView(interactor: ProfileInteractorStub(), store: .preview)
        .environment(DesignSystem.shared)
}
