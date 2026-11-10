//
//  SummaryView.swift
//  ChallengeFinal
//
//  Created by Paulo Henrique Costa Alves on 03/11/26.
//

import SwiftUI

enum SummaryStyle {
    case activity
    case display
}

struct SummaryView: View {
    
    /// Estilo do componente (para mudar com base no fluxo)
    let style: SummaryStyle
    
    /// Título do desafio
    let title: String

    /// Descrição do desafio.
    var description: String

    /// Foto do resultado. `nil` = card vazio (pontilhado).
    var photo: Image? = nil

    /// Humor registrado
    let humor: Humor?

    /// Toque em "finalizar".
    let onFinish: () -> Void

    /// Toque em "compartilhar".
    let onShare: () -> Void
    
    
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
                if let humor {
                    EmojiLabelComponent(humor: humor, highlighted: true)
                        .offset(x: 24, y: -28)
                }
            }
    }

    // MARK: - Botões

    private var buttons: some View {
        VStack(spacing: 12) {
            switch style {
            case .activity:
                CustomButtonComponent(
                    title: "finalizar",
                    icon: nil,
                    type: .secondary,
                    action: onFinish
                )
                .bold()
            case .display:
                CustomButtonComponent(
                    title: "tirar outra foto",
                    icon: "arrow.trianglehead.2.clockwise.rotate.90",
                    type: .secondary,
                    action: onFinish
                )
                .bold()
            }
            
            CustomButtonComponent(
                title: "compartilhar",
                icon: "square.and.arrow.up",
                type: .secondary,
                action: onShare
            )
            .bold()
        }
    }
}

#Preview {
    SummaryView(style: .activity,title: "testee", description: "teste", humor: .veryPleasant, onFinish: {}, onShare: {})
        .environment(DesignSystem.shared)
}
