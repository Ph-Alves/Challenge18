//
//  ShareStorySheet.swift
//  ChallengeFinal
//
//  Created by Paulo Henrique Costa Alves on 17/11/26.
//

import SwiftUI

/// Sheet de compartilhar: mostra o `StoryCard` como preview e deixa escolher a variação.
struct ShareStorySheet: View {
    
    // MARK: - Variables
    
    @Environment(DesignSystem.self) private var designSystem
    @Environment(\.dismiss) private var dismiss
    
    let challengeTitle: String
    let challengeDescription: String
    let challengeIcon: String
    
    /// Foto do resultado. `nil` = a opção "foto" fica desabilitada.
    var photo: Image? = nil
    
    /// Toque no botão principal, com a variação escolhida.
    /// `.transparent` baixa o PNG; as outras abrem o compartilhamento.
    let onConfirm: (StoryCardStyle) -> Void
    
    @State private var selectedStyle: StoryCardStyle = .white
    
    private let previewRadius: CGFloat = 16
    
    /// O preview usa o tamanho real do card (`ShareImageSpecification.pointSize`).
    private var previewSize: CGSize {
        ShareImageSpecification.pointSize
    }
    
    // MARK: - View
    
    var body: some View {
        VStack(spacing: 0) {
            header
            
            Spacer(minLength: 16)
            
            preview
            
            Spacer(minLength: 20)
            
            styleOptions
            
            confirmButton
                .padding(.top, 24)
                .padding(.horizontal, 90)
            
            Spacer(minLength: 16)
        }
        .padding(.top, 16)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .presentationDetents([.height(540)])
        .presentationCornerRadius(38)
        .presentationBackground(designSystem.style.colors.backgroundPrimary)
    }
    
    // MARK: - Header
    
    private let closeButtonSize: CGFloat = 44
    
    /// X à esquerda, título no centro e um espaço do mesmo tamanho do X à direita,
    /// para o título ficar centralizado sem depender de `overlay`.
    private var header: some View {
        HStack(spacing: 0) {
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 18, weight: .regular))
                    .foregroundStyle(designSystem.style.colors.textPrimary)
                    .frame(width: closeButtonSize, height: closeButtonSize)
                    .background(designSystem.style.colors.textPrimary.opacity(0.1), in: Circle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel("fechar")
            
            Text("compartilhar")
                .font(designSystem.style.typography.text2)
                .foregroundStyle(designSystem.style.colors.textPrimary)
                .frame(maxWidth: .infinity)
            
            Color.clear
                .frame(width: closeButtonSize, height: closeButtonSize)
        }
        .padding(.horizontal, 16)
    }
    
    // MARK: - Preview
    
    private var preview: some View {
        ZStack {
            if selectedStyle == .transparent {
                CheckerboardView()
            }
            
            StoryCard(
                challengeTitle: challengeTitle,
                challengeDescription: challengeDescription,
                challengeIcon: challengeIcon,
                style: selectedStyle,
                challengePhotoImage: photo
            )
            .frame(width: previewSize.width, height: previewSize.height)
        }
        .frame(width: previewSize.width, height: previewSize.height)
        .clipShape(RoundedRectangle(cornerRadius: previewRadius))
        .overlay {
            RoundedRectangle(cornerRadius: previewRadius)
                .stroke(designSystem.style.colors.strokeDefault, lineWidth: 1)
        }
    }
    
    // MARK: - Opções
    
    private var styleOptions: some View {
        // Largura fixa por botão: a soma (4 x 60 + espaços) precisa caber na tela,
        // senão o VStack inteiro fica mais largo que a sheet e o cabeçalho sai da tela.
        HStack(spacing: 12) {
            ForEach(StoryCardStyle.allCases, id: \.self) { style in
                optionButton(style)
            }
        }
    }
    
    private func optionButton(_ style: StoryCardStyle) -> some View {
        let isSelected = selectedStyle == style
        let isEnabled = style != .photo || photo != nil
        
        return Button {
            selectedStyle = style
        } label: {
            VStack(spacing: 8) {
                optionSwatch(style, isSelected: isSelected)
                    .frame(width: 28, height: 28)
                
                Text(style.title)
                    .font(designSystem.style.typography.text3)
                    .foregroundStyle(isSelected ? designSystem.style.colors.textInverse : designSystem.style.colors.textPrimary)
            }
            .padding(.horizontal, 13)
            .padding(.vertical, 8.5)
            .background(
                isSelected ? designSystem.style.colors.backgroundInverse : Color.clear,
                in: RoundedRectangle(cornerRadius: 8)
            )
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled)
        .opacity(isEnabled ? 1 : 0.4)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
    
    /// Bolinha que representa a variação.
    @ViewBuilder
    private func optionSwatch(_ style: StoryCardStyle, isSelected: Bool) -> some View {
        // Quando o botão está selecionado o fundo é escuro, então o contorno inverte.
        let stroke = isSelected ? designSystem.style.colors.textInverse : designSystem.style.colors.strokeDefault
        
        switch style {
        case .white:
            Circle().fill(Color.white)
                .overlay { Circle().stroke(stroke, lineWidth: 1) }
        case .black:
            Circle().fill(Color.black)
                .overlay { Circle().stroke(stroke, lineWidth: 1) }
        case .photo:
            Circle().fill(Color.white)
                .overlay {
                    if let photo {
                        photo
                            .resizable()
                            .scaledToFill()
                            .saturation(0)
                            .clipShape(Circle())
                    }
                }
                .overlay { Circle().stroke(stroke, lineWidth: 1) }
        case .transparent:
            CheckerboardView(squareSize: 6)
                .clipShape(Circle())
                .overlay { Circle().stroke(stroke, lineWidth: 1) }
        }
    }
    
    // MARK: - Botão principal
    
    private var confirmButton: some View {
        CustomButtonComponent(
            title: selectedStyle == .transparent ? "baixar png" : "compartilhar",
            icon: selectedStyle == .transparent ? nil : designSystem.style.icons.shareIcon.card,
            type: .primary
        ) {
            onConfirm(selectedStyle)
        }
    }
}

// MARK: - Título das opções

private extension StoryCardStyle {
    var title: String {
        switch self {
        case .white: return "branco."
        case .black: return "preto."
        case .photo: return "foto!"
        case .transparent: return "png"
        }
    }
}

// MARK: - Xadrez (indica transparência)

private struct CheckerboardView: View {
    var squareSize: CGFloat = 12
    
    var body: some View {
        Canvas { context, size in
            context.fill(Path(CGRect(origin: .zero, size: size)), with: .color(Color(white: 0.95)))
            
            let columns = Int((size.width / squareSize).rounded(.up))
            let rows = Int((size.height / squareSize).rounded(.up))
            
            for row in 0..<rows {
                for column in 0..<columns where (row + column).isMultiple(of: 2) {
                    let square = CGRect(
                        x: CGFloat(column) * squareSize,
                        y: CGFloat(row) * squareSize,
                        width: squareSize,
                        height: squareSize
                    )
                    context.fill(Path(square), with: .color(Color(white: 0.8)))
                }
            }
        }
    }
}

// MARK: - Previews

// Mostram o conteúdo direto (o snapshot de `.sheet` sai em branco, a sheet ainda está animando).
// 506 pt = detent de 540 menos ~34 pt da safe area: o espaço que a sheet realmente tem.

#Preview("sem foto") {
    ShareStorySheet(
        challengeTitle: "mestre offline",
        challengeDescription: "você passou 1h se exercitando sem entrar em nenhuma rede social",
        challengeIcon: ActivityCategory.physical.closedIcon,
        onConfirm: { _ in }
    )
    .frame(height: 506)
    .frame(maxHeight: .infinity, alignment: .top)
    .environment(DesignSystem.shared)
}

#Preview("com foto") {
    ShareStorySheet(
        challengeTitle: "mestre offline",
        challengeDescription: "você passou 1h se exercitando sem entrar em nenhuma rede social",
        challengeIcon: ActivityCategory.physical.closedIcon,
        photo: Image("challengePhoto"),
        onConfirm: { _ in }
    )
    .frame(height: 506)
    .frame(maxHeight: .infinity, alignment: .top)
    .environment(DesignSystem.shared)
}
