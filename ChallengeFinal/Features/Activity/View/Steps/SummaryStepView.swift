//
//  SummaryStepView.swift
//  ChallengeFinal
//
//  Created by Raquel Souza on 27/10/26.
//

import SwiftUI

/// Step `.summary` do fluxo de Activity (tela "desafio finalizado" do protótipo).
///
struct SummaryStepView: View {

    // MARK: - Variables

    /// Título do desafio
    let title: String

    /// Descrição do desafio.
    var description: String

    /// Foto do resultado. `nil` = card vazio (pontilhado).
    var photo: Image? = nil

    /// Humor registrado
    let humor: Humor

    /// Toque em "finalizar".
    let onFinish: () -> Void

    /// Toque em "compartilhar".
    let onShare: () -> Void

    // MARK: - View

    var body: some View {
        VStack(spacing: 0) {
            header
                .padding(.top, 40)

            photoCard
                .padding(.top, 36)

            Spacer(minLength: 24)

            buttons
                .padding(.bottom, 32)
        }
        .padding(.horizontal, 40)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)
    }

    // MARK: - Título

    private var header: some View {
        VStack(spacing: 0) {
            ChallengeCircle(text: "você conseguiu!", size: .small)

            Text(title)
                .font(.system(size: 22, weight: .bold))
                .padding(.top, 16)

            Text(description)
                .font(.system(size: 16))
                .fixedSize(horizontal: false, vertical: true)   // quebra linha em vez de cortar
                .padding(.top, 8)
        }
        .multilineTextAlignment(.center)
        .foregroundStyle(.black)
    }

    // MARK: - Foto + humor

    private var photoCard: some View {
        PhotoCard(photo: photo, height: 228)
            // O selo de humor fica "pendurado" no canto de cima, como no protótipo.
            .overlay(alignment: .topTrailing) {
                EmojiLabelComponent(humor: humor, highlighted: true)
                    .offset(x: 24, y: -28)
            }
    }

    // MARK: - Botões

    private var buttons: some View {
        HStack(spacing: 12) {
            CustomButtonComponent(
                title: "finalizar",
                icon: nil,
                type: .secondary,
                action: onFinish
            )

            CustomButtonComponent(
                title: "compartilhar",
                icon: "square.and.arrow.up",
                type: .secondary,
                action: onShare
            )
        }
    }
}

// MARK: - Previews

#Preview("Sem foto") {
    SummaryStepView(
        title: "menos distração, mais foco",
        description: "sem redes sociais, seu cardio vira um momento para cuidar do corpo e desacelerar a mente.",
        humor: .frustrated,
        onFinish: { print("finalizar") },
        onShare: { print("compartilhar") }
    )
}

#Preview("Com foto") {
    SummaryStepView(
        title: "menos distração, mais foco",
        description: "sem redes sociais, seu cardio vira um momento para cuidar do corpo e desacelerar a mente.",
        photo: Image(systemName: "person.crop.square.fill"), // só para visualizar
        humor: .calm,
        onFinish: { print("finalizar") },
        onShare: { print("compartilhar") }
    )
}
