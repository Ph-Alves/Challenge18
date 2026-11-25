//
//  ProfileHeaderView.swift
//  ChallengeFinal
//
//  Created by Raquel Souza on 16/11/26.
//

import SwiftUI
import PhotosUI

/// Cabeçalho do perfil só monta os componentes
/// Recebe dados, bindings e closures (não conhece Store nem Interactor).
struct ProfileHeaderView: View {
    @Environment(DesignSystem.self) private var designSystem

    let name: String
    let userPhoto: Image?
    let streakDayCount: String
    let levelTitle: String
    let levelSubtitle: String
    let isEditing: Bool
    @Binding var draftName: String
    @Binding var photoItem: PhotosPickerItem?
    var isNameFocused: FocusState<Bool>.Binding
    let editAction: () -> Void
    let settingsAction: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                HeaderCircleButton(systemName: isEditing ? "checkmark" : "pencil", action: editAction)
                Spacer()
                PhotosPicker(selection: $photoItem, matching: .images) {
                    ProfilePicture(userPhoto: userPhoto, isEditing: isEditing)
                }
//                .buttonStyle(.plain)
                .disabled(!isEditing)
                Spacer()
                HeaderCircleButton(systemName: "gear", action: settingsAction)
                    .opacity(isEditing ? 0.4 : 1)
                    .disabled(isEditing)
            }

            ProfileNameField(
                name: name,
                isEditing: isEditing,
                draftName: $draftName,
                isFocused: isNameFocused,
                onSubmit: editAction
            )

            StreakProfileCard(streakDateCount: streakDayCount, title: levelTitle, subtitle: levelSubtitle)
        }
        .padding(.horizontal, 30)
        .padding(.top, 78)      
        .padding(.bottom, 38)
        .background {
            Image(designSystem.style.profile.headerBackground)
                .resizable()
        }
    }
}

// MARK: - Botão circular de vidro (lápis e engrenagem)

private struct HeaderCircleButton: View {
    @Environment(DesignSystem.self) private var designSystem

    // 20 e 44 no tamanho padrão, acompanhando o Dynamic Type
    @ScaledMetric(relativeTo: .title2) private var iconSize: CGFloat = 24
    @ScaledMetric(relativeTo: .title2) private var buttonSize: CGFloat = 40

    let systemName: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemName)
                .resizable()
                .scaledToFit()
                .frame(width: iconSize, height: iconSize)
                .foregroundStyle(designSystem.style.colors.fillConstantDark)
                .frame(width: buttonSize, height: buttonSize)
                .contentTransition(.symbolEffect(.replace))
        }
        .buttonStyle(.glass)
        .buttonBorderShape(.circle)
    }
}


// MARK: - Preview

#Preview("Perfil - interativo") {
    @Previewable @State var isEditing = false
    @Previewable @State var name = "Raquel"
    @Previewable @State var draftName = "Raquel"
    @Previewable @State var photoItem: PhotosPickerItem?
    @Previewable @FocusState var isNameFocused: Bool

    ZStack {
        ProfileHeaderView(
            name: name,
            userPhoto: nil,
            streakDayCount: "12",
            levelTitle: "explorador",
            levelSubtitle: "faltam 3 desafios para o próximo nível",
            isEditing: isEditing,
            draftName: $draftName,
            photoItem: $photoItem,
            isNameFocused: $isNameFocused,
            editAction: {
                withAnimation {
                    if isEditing { name = draftName }
                    isEditing.toggle()
                    isNameFocused = isEditing
                }
            },
            settingsAction: { print("abrir configurações") }
        )
    }
    .environment(DesignSystem.shared)
}

#Preview("Perfil - editando") {
    @Previewable @State var draftName = "Raquel"
    @Previewable @State var photoItem: PhotosPickerItem?
    @Previewable @FocusState var isNameFocused: Bool

    ProfileHeaderView(
        name: "Raquel",
        userPhoto: Image(systemName: "person.crop.circle.fill"),
        streakDayCount: "30",
        levelTitle: "mestre",
        levelSubtitle: "você está on fire!",
        isEditing: true,
        draftName: $draftName,
        photoItem: $photoItem,
        isNameFocused: $isNameFocused,
        editAction: {},
        settingsAction: {}
    )
    .frame(maxHeight: .infinity, alignment: .top)
    .ignoresSafeArea(edges: .top)
    .environment(DesignSystem.shared)
}
