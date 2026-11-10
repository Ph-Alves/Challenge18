//
//  StoryCard.swift
//  ChallengeFinal
//
//  Created by Raquel Souza on 27/10/26.
//

/// Template da imagem compartilhada. 

import SwiftUI

struct StoryCard: View {
    
    // MARK: - Variables
    
    //Título do Desafio
    let challengeTitle: String
    
    //Descrição do Desafio
    let challengeDescription: String
    
    /// Foto do `ActivityResult`. `nil` = fundo branco (story 1); com foto = story 2.
    var challengePhoto: UIImage? = nil
    
    let challengeIcon: String

    private let size = ShareImageSpecification.pointSize
    @Environment(DesignSystem.self) private var designSystem
    @Environment(\.colorScheme) private var colorScheme

    // MARK: - View
    var body: some View {
        content
            .frame(maxWidth: .infinity, maxHeight: .infinity)   // conteúdo centralizado na tela
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
                .environment(\.colorScheme, challengePhoto != nil ? .dark : colorScheme)

            VStack(spacing: 12) {
                Text(challengeTitle)
                    .font(designSystem.style.typography.title3)
                    .foregroundStyle(challengePhoto != nil ? Color.white : designSystem.style.colors.textPrimary)
                
                Text(challengeDescription)
                    .font(designSystem.style.typography.text2)
                    .foregroundStyle(challengePhoto != nil ? Color.white : designSystem.style.colors.textPrimary)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
        //CHANGE: trocar pelo nome real
            Text("selfmaxxing.")
                .font(designSystem.style.typography.title4)
                .foregroundStyle(challengePhoto != nil ? Color.white : designSystem.style.colors.textPrimary)
                .padding(.top, 58)
        }
        .frame(maxWidth: 260)
        .multilineTextAlignment(.center)
        .foregroundStyle(challengePhoto != nil ?  designSystem.style.colors.textInverse : designSystem.style.colors.textPrimary)
    }
    
    // MARK: - Foto como Background
    @ViewBuilder
    private var backgroundLayer: some View {
        if let challengePhoto {
            // O Color.clear ocupa exatamente o espaço disponível; a foto entra
            // como overlay, preenche esse espaço e o .clipped() corta o que sobra.
            Color.clear
                .overlay {
                    Image(uiImage: challengePhoto)
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
            designSystem.style.colors.textInverse
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

