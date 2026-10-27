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
    static let pointSize = CGSize(width: 360, height: 640)
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
            content: content.frame(width: size.width, height: size.height)
        )
        renderer.proposedSize = ProposedViewSize(size)
        renderer.scale = scale
        return renderer.uiImage
    }
}
