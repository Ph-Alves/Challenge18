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
    
    // MARK: - Estado do desafio aberto

    /// Os três jeitos de visualizar um desafio já aberto.
    private enum DisplayState {
        /// Sem foto → botão "adicionar foto".
        case withoutPhoto
        /// Com foto → botão "substituir foto".
        case withPhoto
        /// Sem humor registrado → ganha o botão "reflita!".
        case withoutFeeling
    }

    /// Calculado a partir do que a view já recebe.
    /// Sem humor tem prioridade, porque é o único que muda o layout.
    private var displayState: DisplayState {
        if humor == nil { return .withoutFeeling }
        if photo == nil { return .withoutPhoto }
        return .withPhoto
    }
    
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
    
    /// Toque em "reflita!" (só aparece no `.display` quando não há humor registrado).
    var onReflect: () -> Void = {}
    
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
            .overlay(alignment: .topTrailing) {
                if let humor {
                    EmojiLabelComponent(humor: humor, highlighted: true)
                        .offset(x: 24, y: -28)
                }
            }
    }

    // MARK: - Botões
    @ViewBuilder
    private var buttons: some View {
        VStack(spacing: 12) {
            switch style {
            case .activity:
                activityButtons
            case .display:
                switch displayState {
                case .withoutFeeling:
                    withoutFeelingButtons
                case .withPhoto, .withoutPhoto:
                    photoButtons
                }
            }
        }
    }
    
    //MARK: - Grupos de botões utilizados em cada caso.
    @ViewBuilder
    private var activityButtons: some View {
        CustomButtonComponent(title: "finalizar", icon: nil, type: .secondary, action: onFinish)
            .bold()
        shareButton(type: .secondary)
    }

    @ViewBuilder
    private var photoButtons: some View {
        shareButton(type: .primary)
        photoButton(type: .secondary)
    }

    @ViewBuilder
    private var withoutFeelingButtons: some View {
        CustomButtonComponent(title: "reflita!", icon: nil, type: .primary, action: onReflect)
            .bold()
        shareButton(type: .secondary)
        photoButton(type: .tertiary)
    }
    
    //MARK: - Botões reutilizáveis ao longo das subviews
    
    private func shareButton(type: CustomButtonType) -> some View {
        CustomButtonComponent(title: "compartilhar", icon: "arrow.clockwise", type: type, action: onShare)
            .bold()
    }
    
    private func photoButton(type: CustomButtonType) -> some View {
        CustomButtonComponent(
            title: photo == nil ? "adicionar foto" : "substituir foto",
            icon: nil,
            type: type,
            action: onFinish
        )
        .bold()
    }
}

#Preview {
    SummaryView(style: .activity,title: "testee", description: "teste", humor: .veryPleasant, onFinish: {}, onShare: {})
}
