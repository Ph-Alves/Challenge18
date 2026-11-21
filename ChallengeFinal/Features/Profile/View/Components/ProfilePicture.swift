//
//  ProfilePicture.swift
//  ChallengeFinal
//
//  Created by Raquel Souza on 17/11/26.
//

import SwiftUI

/// Default: foto do usuário (ou placeholder). Edit: fundo claro com ícone de câmera.
struct ProfilePicture: View {
    @Environment(DesignSystem.self) private var designSystem

    let userPhoto: Image?
    let isEditing: Bool

    private var colors: ColorPalette { designSystem.style.colors }
    private var icons: IconsSet { designSystem.style.icons }

    var body: some View {
        ZStack {
            Circle()
                .fill(colors.fillConstantLight)

            if isEditing {
                Image(icons.cameraIcon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 44, height: 26)
            } else if let userPhoto {
                userPhoto
                    .resizable()
                    .scaledToFill()
            } else {
                Image(icons.profilePlaceholder)
                    .resizable()
                    .scaledToFit()
            }
        }
        .frame(width: 98, height: 98)
        .clipShape(Circle())
        .overlay(Circle().stroke(colors.strokeConstantDark, lineWidth: 1))
        .animation(.easeInOut(duration: 0.2), value: isEditing)
        .accessibilityLabel(isEditing ? "trocar foto" : "foto de perfil")
    }
}

#Preview {
    HStack(spacing: 20) {
        ProfilePicture(userPhoto: nil, isEditing: false)
        ProfilePicture(userPhoto: nil, isEditing: true)
    }
    .padding()
    .background(.gray)
    .environment(DesignSystem.shared)
}
