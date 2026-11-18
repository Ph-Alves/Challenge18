//
//  StoryCard.swift
//  ChallengeFinal
//
//  Created by Raquel Souza on 27/10/26.
//

/// Template da imagem compartilhada. 

import SwiftUI

/// Variações do story escolhidas na sheet de compartilhar.
enum StoryCardStyle: CaseIterable {
    /// Fundo branco, ícone e texto pretos.
    case white
    /// Fundo preto, ícone e texto brancos.
    case black
    /// Foto em preto e branco de fundo, ícone e texto brancos.
    case photo
    /// Fundo transparente (PNG), só ícone e texto brancos.
    case transparent
}

struct StoryCard: View {
    
    // MARK: - Variables
    
    //Título do Desafio
    let challengeTitle: String
    
    //Descrição do Desafio
    let challengeDescription: String
    
    /// Foto do `ActivityResult`. `nil` = fundo branco (story 1); com foto = story 2.
    var challengePhoto: UIImage? = nil
    
    let challengeIcon: String
    
    /// `nil` = comportamento original: com foto vira `.photo`, sem foto vira `.white`.
    var style: StoryCardStyle? = nil
    
    /// Foto já como `Image`, para quem não tem o `UIImage` (ex.: preview da sheet de compartilhar).
    /// Tem prioridade sobre `challengePhoto`.
    var challengePhotoImage: Image? = nil
    
    private var photoImage: Image? {
        challengePhotoImage ?? challengePhoto.map { Image(uiImage: $0) }
    }

    private let size = ShareImageSpecification.pointSize
    
    /// Largura em que o conteúdo (ícone, textos, margens) foi desenhado.
    /// Em tamanhos menores o conteúdo é reduzido na mesma proporção.
    private let designWidth: CGFloat = 360
    
    private var contentScale: CGFloat { size.width / designWidth }
    @Environment(DesignSystem.self) private var designSystem
    @Environment(\.colorScheme) private var colorScheme
    
    private var resolvedStyle: StoryCardStyle {
        style ?? (photoImage != nil ? .photo : .white)
    }
    
    /// Cor do texto e do ícone: preto só no fundo branco.
    private var foregroundColor: Color {
        resolvedStyle == .white ? .black : .white
    }

    // MARK: - View
    var body: some View {
        content
            .frame(width: designWidth, height: size.height / contentScale)
            .scaleEffect(contentScale)
            .frame(width: size.width, height: size.height)      // scaleEffect não muda o layout: fixa no tamanho do card
            .background {
                backgroundLayer
                    .ignoresSafeArea()                          // só o fundo vai até as bordas
            }
            .dynamicTypeSize(.large)
    }
    
    // MARK: - Conteúdo
    
    private var content: some View {
        VStack(spacing: 16) {
            
            Image(challengeIcon)
                .resizable()
                .frame(maxWidth: 96, maxHeight: 96)
                .environment(\.colorScheme, resolvedStyle == .white ? .light : .dark)

            VStack(spacing: 12) {
                Text(challengeTitle)
                    .font(designSystem.style.typography.title3)
                    .foregroundStyle(foregroundColor)
                
                Text(challengeDescription)
                    .font(designSystem.style.typography.text2)
                    .foregroundStyle(foregroundColor)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
        //CHANGE: trocar pelo nome real
            Text("selfmaxxing.")
                .font(designSystem.style.typography.title4)
                .foregroundStyle(foregroundColor)
                .padding(.top, 58)
        }
        .frame(maxWidth: 260)
        .multilineTextAlignment(.center)
        .foregroundStyle(foregroundColor)
    }
    
    // MARK: - Background
    @ViewBuilder
    private var backgroundLayer: some View {
        switch resolvedStyle {
        case .white:
            Color.white
        case .black:
            Color.black
        case .transparent:
            Color.clear
        case .photo:
            photoBackground
        }
    }
    
    // MARK: - Foto como Background
    @ViewBuilder
    private var photoBackground: some View {
        if let photoImage {
            // O Color.clear ocupa exatamente o espaço disponível; a foto entra
            // como overlay, preenche esse espaço e o .clipped() corta o que sobra.
            Color.clear
                .overlay {
                    photoImage
                        .resizable()
                        .scaledToFill()
                        .saturation(designSystem.style.photoFilter?.saturation ?? 0)
                }
                .clipped()
                .overlay(
                    designSystem.style.photoFilter?.overlayColor
                        .opacity(designSystem.style.photoFilter?.overlayOpacity ?? 0.6)
                    ?? Color.black.opacity(0.6)
                )
        } else {
            // estilo .photo sem foto disponível: cai no preto
            Color.black
        }
    }

}

// MARK: - Previews
#Preview("Story 1 - sem foto") {
    StoryCard(
        challengeTitle: "menos distração, mais foco",
        challengeDescription: "sem redes sociais, seu cardio vira um momento para cuidar do corpo e desacelerar a mente.", challengeIcon: ActivityCategory.sensorial.closedIcon
    ).environment(DesignSystem.shared)
}

#Preview("Story 2 - com foto") {
    StoryCard( 
        challengeTitle: "menos distração, mais foco",
        challengeDescription: "sem redes sociais, seu cardio vira um momento para cuidar do corpo e desacelerar a mente.",
        challengePhoto: UIImage(named: "challengePhoto"), challengeIcon: ActivityCategory.sensorial.closedIcon
    ).environment(DesignSystem.shared)
}

