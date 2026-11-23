//
//  ShareImageRenderer.swift
//  ChallengeFinal
//
//  Created by Raquel Souza on 27/10/26.
//

import SwiftUI

/// Esse arquivo aqui vai transformar uma View SwiftUI em `UIImage`

// MARK: - Especificação da imagem

/// Desenhamos em 360x640 pt e renderizamos com scale 3 => 1080x1920 px (tamanho de Stories).
enum ShareImageSpecification {
    static let pointSize = CGSize(width: 161, height: 224)
    static let scale: CGFloat = 3

    /// Fotos da câmera têm ~12 MP. Reduzimos antes de usar no card para poupar memória:
    /// 1920 px já cobre o lado maior do story.
    static let maxPhotoDimension: CGFloat = 1920
}


// MARK: - Renderização (View -> UIImage)

@MainActor
enum ShareImageRenderer {

    /// Devolve `nil` se a renderização falhar.
    static func render<Content: View>(
        _ content: Content,
        size: CGSize = ShareImageSpecification.pointSize,
        scale: CGFloat = ShareImageSpecification.scale
    ) -> UIImage? {
        let renderer = ImageRenderer(
            // O ImageRenderer roda fora da hierarquia do app: o environment precisa ser injetado aqui.
            content: content
                .frame(width: size.width, height: size.height)
                .environment(DesignSystem.shared)
        )
        renderer.proposedSize = ProposedViewSize(size)
        renderer.scale = scale
        return renderer.uiImage
    }
    
    /// Renderiza o story em todas as variações da sheet de compartilhar.
    /// `.photo` só entra quando há foto. Variação que falhar fica de fora do dicionário.
    static func renderAllStyles(
        title: String,
        description: String,
        photo: UIImage?,
        icon: String
    ) -> [StoryCardStyle: UIImage] {
        var images: [StoryCardStyle: UIImage] = [:]
        
        for style in StoryCardStyle.allCases where style != .photo || photo != nil {
            let story = StoryCard(
                challengeTitle: title,
                challengeDescription: description,
                challengePhoto: photo,
                challengeIcon: icon,
                style: style
            )
            images[style] = render(story)
        }
        return images
    }
}
