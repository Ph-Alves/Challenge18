//
//  ProfileView.swift
//  ChallengeFinal
//
//  Created by Raquel Souza on 16/10/26.
//

import SwiftUI
import PhotosUI

/// Tela de Perfil. Só lê da Store e repassa as ações ao Interactor.
///
/// Monta: cabeçalho (lápis, foto, engrenagem, nome e streak) + seção "temas".
struct ProfileView: View {

    // MARK: - Variables

    @Environment(DesignSystem.self) private var designSystem
    @Environment(\.openURL) private var openURL

    /// Pelo protocolo, para dar para passar um Interactor falso no preview.
    let interactor: ProfileInteractorProtocol

    /// Estado da tela. A View segura com força (o Presenter guarda como `weak`).
    @State var store: ProfileStore

    /// Item escolhido na galeria (estado de UI; os bytes quem carrega é o Interactor).
    @State private var photoItem: PhotosPickerItem?

    /// Foco do campo de nome: abre o teclado ao entrar no modo edição.
    @FocusState private var isNameFocused: Bool

    // MARK: - DS atalhos

    private var typography: Typography { designSystem.style.typography }
    private var colors: ColorPalette { designSystem.style.colors }

    // MARK: - Body

    var body: some View {
        VStack(spacing: 50) {
            ProfileHeaderView(
                name: store.name,
                userPhoto: store.userPhoto,
                streakDayCount: store.streakText,
                levelTitle: store.levelTitle,
                levelSubtitle: store.levelSubtitle,
                isEditing: store.isEditing,
                draftName: $store.draftName,
                photoItem: $photoItem,
                isNameFocused: $isNameFocused,
                editAction: editAction,
                settingsAction: interactor.openSettings
            )

            themesSection

        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .ignoresSafeArea(edges: .top)
        .background(colors.backgroundPrimary)
        .foregroundStyle(colors.textPrimary)
        .onAppear(perform: interactor.fetchProfile)
        // Foto: a View só avisa; o Interactor carrega e salva.
        .onChange(of: photoItem) { _, newItem in
            guard let newItem else { return }
            interactor.didSelectPhoto(newItem)
            photoItem = nil
        }
        // Teclado acompanha o modo edição decidido pelo Interactor.
        .onChange(of: store.isEditing) { _, isEditing in
            isNameFocused = isEditing
        }
        // Engrenagem
        .sheet(isPresented: $store.isSettingsPresented, onDismiss: interactor.closeSettings) {
            SettingsView(
                notifications: store.notifications,
                closeAction: interactor.closeSettings,
                notificationsAction: interactor.updateNotifications,
            )
            // Permissão negada aparece por cima do sheet, que é onde o toggle foi tocado.
            .alert("Permissão necessária", isPresented: isPermissionAlertPresented) {
                permissionAlertButtons
            } message: {
                Text(store.permissionAlertMessage ?? "")
            }
        }
        // Erros técnicos (ex.: foto não carregou)
        .alert("Ops!", isPresented: isErrorPresented) {
            Button("OK", role: .cancel, action: interactor.dismissAlerts)
        } message: {
            Text(store.errorMessage ?? "")
        }
    }

    // MARK: - Temas

    private var themesSection: some View {
        VStack(alignment: .leading, spacing: 28) {
            VStack(alignment: .leading, spacing: 2) {
                Text("temas")
                    .font(typography.title1)
                Text("escolha um tema e deixe o app a sua cara")
                    .font(typography.text2)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: 24) {
                ForEach(store.themes, id: \.self) { theme in
                    ThemeCard(theme: theme, isSelected: store.currentTheme == theme) {
                        interactor.updateTheme(theme)
                    }
                }
            }
            .frame(maxWidth: .infinity)
        }
        .padding(.horizontal, 30)
    }

    // MARK: - Ações

    /// Lápis vira "check": o primeiro toque entra em edição, o segundo salva.
    private func editAction() {
        if store.isEditing {
            interactor.saveEditing(name: store.draftName)
        } else {
            interactor.startEditing()
        }
    }

    // MARK: - Alertas

    /// As mensagens são `private(set)` na Store: fechar o alerta passa pelo Interactor.
    private var isPermissionAlertPresented: Binding<Bool> {
        Binding(
            get: { store.permissionAlertMessage != nil },
            set: { if !$0 { interactor.dismissAlerts() } }
        )
    }

    private var isErrorPresented: Binding<Bool> {
        Binding(
            get: { store.errorMessage != nil },
            set: { if !$0 { interactor.dismissAlerts() } }
        )
    }

    @ViewBuilder
    private var permissionAlertButtons: some View {
        Button("abrir ajustes") {
            interactor.dismissAlerts()
            if let url = URL(string: UIApplication.openSettingsURLString) {
                openURL(url)
            }
        }
        Button("agora não", role: .cancel, action: interactor.dismissAlerts)
    }
}

// MARK: - Preview

/// Interactor falso: só fala com a Store, sem banco nem permissões.
@MainActor
private final class ProfileInteractorPreview: ProfileInteractorProtocol {
    let store: ProfileStore
    init(store: ProfileStore) { self.store = store }

    func fetchProfile() {}
    func startEditing() { store.displayEditing(isEditing: true, draftName: store.name) }
    func saveEditing(name: String) {
        store.displayProfile(name: name.isEmpty ? store.name : name, userPhoto: store.userPhoto)
        store.displayEditing(isEditing: false, draftName: name)
    }
    func didSelectPhoto(_ item: PhotosPickerItem) {}
    func updateTheme(_ theme: Theme) { store.displayTheme(theme) }
    func openSettings() { store.displaySettingsSheet(isPresented: true) }
    func closeSettings() { store.displaySettingsSheet(isPresented: false) }
    
    func updateNotifications(_ isOn: Bool) {
        store.displaySettings(notifications: isOn)
    }
    
    func dismissAlerts() {
        store.displayPermissionAlert(nil)
        store.displayError(nil)
    }
}

#Preview {
    let store = ProfileStore()
    store.displayStreak(streakText: "0 dias", levelTitle: "começando :)",
                        levelSubtitle: "07 dias priorizando seu bem estar :)")

    return ProfileView(interactor: ProfileInteractorPreview(store: store), store: store)
        .environment(DesignSystem.shared)
}
