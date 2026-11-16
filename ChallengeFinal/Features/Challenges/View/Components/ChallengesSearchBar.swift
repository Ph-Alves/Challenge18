//
//  ChallengesSearchBar.swift
//  ChallengeFinal
//
//  Created by Raquel Souza on 03/11/26.
//

import SwiftUI

struct ChallengesSearchBar: View {
    @Environment(DesignSystem.self) private var designSystem
    @Binding var text: String

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .font(.title3)
                .foregroundStyle(designSystem.style.colors.backgroundInverse)

            TextField("placeholder...", text: $text)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .submitLabel(.search)

            if !text.isEmpty {
                Button {
                    text = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.gray)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("limpar busca")
            }
        }
        .padding(.horizontal, 14)
        .frame(height: 44)
        .background(
            Capsule()
                .fill(designSystem.style.colors.backgroundPrimary)
                .shadow(color: designSystem.style.colors.backgroundInverse.opacity(0.12), radius: 8, y: 2)
        )
    }
}
