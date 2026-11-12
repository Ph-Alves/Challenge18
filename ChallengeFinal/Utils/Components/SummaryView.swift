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

enum HumorBadgePosition {
    /// Canto superior direito, "vazando" para fora do card
    case topHumorPosition
    /// Canto inferior direito, dentro do card (posição atual)
    case bottomHumorPosition

    var alignment: Alignment {
        switch self {
        case .topHumorPosition: return .bottomTrailing
        case .bottomHumorPosition:    return .topTrailing
        }
    }

    var offset: CGSize {
        switch self {
        case .topHumorPosition: return CGSize(width: 18, height: -180)
        case .bottomHumorPosition: return CGSize(width: -40, height: 0)
        }
    }
}

struct SummaryView: View {
    
    //MARK: Design System
    @Environment(DesignSystem.self) private var designSystem

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
    
    /// Com foto o humor sobe para o canto superior direito.
    /// Nos outros casos ele fica no canto inferior direito.
    private var humorPosition: HumorBadgePosition {
        guard displayState == .withPhoto else {
            return .bottomHumorPosition
        }
        return .topHumorPosition
    }
    
    /// Estilo do componente (para mudar com base no fluxo)
    let style: SummaryStyle
    
    /// Categoria do desafio (define o ícone do círculo).
    let category: ActivityCategory
    
    /// Data de criação já formatada. `nil` = não exibe.
    var createdAt: String? = nil
    
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
            
            photoCard
                .padding(.top, 36)
                .padding(.bottom, 72)
            
            buttons
                .padding(.bottom, 28)
        }
        .padding(.horizontal, 40)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .navigationTitle(createdAt ?? "")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var header: some View {
        VStack(spacing: 0) {
            
            ChallengeCircle(category: category, text: nil, isOpen: false)
                .scaleEffect(72 / 346)
                .frame(width: 72, height: 72)
            
            Text(title)
                .font(designSystem.currentTheme.style.typography.title3)
                .padding(.top, 16)
            
            Text(description)
                .font(designSystem.currentTheme.style.typography.text2)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, 12)
        }
        .multilineTextAlignment(.center)
    }
    
    /// Data de criação no centro da navigation bar. `nil` = não exibe nada.
    @ToolbarContentBuilder
    private var titleToolbar: some ToolbarContent {
        if let createdAt {
            ToolbarItem(placement: .principal) {
                Text(createdAt)
                    .font(designSystem.currentTheme.style.typography.text2)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
        }
    }
    
    // MARK: - Foto + humor
    
    private var photoCard: some View {
        PhotoCard(photo: photo, height: 260)
//            .frame(width: 160)
            .overlay(alignment: .bottomTrailing) {
                if let humor {
                    EmojiLabelComponent(humor: humor, highlighted: true)
                        .offset(humorPosition.offset)
                }
            }
    }
    
    // MARK: - Botões
    @ViewBuilder
    private var buttons: some View {
        VStack(spacing: 24) {
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
        .frame(width: 213)
    }
    
    //MARK: - Grupos de botões utilizados em cada caso.
    @ViewBuilder
    //botoes da tela summary view no fluxo de atividade
    private var activityButtons: some View {
        CustomButtonComponent(title: "finalizar", icon: nil, type: .secondary, action: onFinish)
            .bold()
        shareButton(type: .primary)
    }
    
    @ViewBuilder
    //botoes da summaryview quando um desafio é aberto e possui foto e humor.
    private var photoButtons: some View {
        photoButton(type: .primary)
        shareButton(type: .secondary)
    }
    
    @ViewBuilder
    //botoes da summaryview quando um desafio é aberto e nao possui humor.
    private var withoutFeelingButtons: some View {
        CustomButtonComponent(title: "reflita!", icon: nil, type: .primary, action: onReflect)
        photoButton(type: .secondary)
        shareButton(type: .tertiary)
    }
    
    //MARK: - Botões reutilizáveis ao longo das subviews
    
    private func shareButton(type: CustomButtonType) -> some View {
        CustomButtonComponent(title: "compartilhar", icon: designSystem.style.icons.shareIcon, type: type, action: onShare)
    }
    
    private func photoButton(type: CustomButtonType) -> some View {
        CustomButtonComponent(
            title: photo == nil ? "adicionar foto" : "trocar foto",
            icon: photo == nil ? nil : designSystem.style.icons.retryIcon.card,
            type: type,
            action: onFinish
        )
    }
}
    
#Preview("display com foto") {
    SummaryView(
        style: .display,
        category: .physical,
        createdAt: "9 de outubro de 2026",
        title: "mestre offline",
        description: "você passou 1h se exercitando sem entrar em nenhuma rede social",
        photo: Image(systemName: "photo"),
        humor: .unpleasant,
        onFinish: {},
        onShare: {}
    )
    .environment(DesignSystem.shared)
}

#Preview("display sem foto") {
    SummaryView(
        style: .display,
        category: .physical,
        createdAt: "9 de outubro de 2026",
        title: "mestre offline",
        description: "você passou 1h se exercitando sem entrar em nenhuma rede social",
        photo: nil,
        humor: .unpleasant,
        onFinish: {},
        onShare: {}
    )
    .environment(DesignSystem.shared)
}

#Preview("activity com foto") {
    SummaryView(
        style: .activity,
        category: .physical,
        createdAt: "9 de outubro de 2026",
        title: "mestre offline",
        description: "você passou 1h se exercitando sem entrar em nenhuma rede social",
        photo: Image(systemName: "photo"),
        humor: .unpleasant,
        onFinish: {},
        onShare: {}
    )
    .environment(DesignSystem.shared)
}

#Preview("activity sem foto") {
    SummaryView(
        style: .activity,
        category: .physical,
        createdAt: "9 de outubro de 2026",
        title: "mestre offline",
        description: "você passou 1h se exercitando sem entrar em nenhuma rede social",
        photo: nil,
        humor: .unpleasant,
        onFinish: {},
        onShare: {}
    )
    .environment(DesignSystem.shared)
}
