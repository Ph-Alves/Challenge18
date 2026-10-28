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
    
    private let size = ShareImageSpecification.pointSize
    
    // MARK: - View
    var body: some View {
        content
            .frame(maxWidth: .infinity, maxHeight: .infinity)   // conteúdo centralizado na tela
            .background {
                backgroundLayer
                    .ignoresSafeArea()                          // só o fundo vai até as bordas
            }
            .environment(\.colorScheme, .light)   // independe do dark mode
            .dynamicTypeSize(.large)              // independe do tamanho de fonte do usuário
    }
    
    // MARK: - Conteúdo
    
    private var content: some View {
        VStack(spacing: 12) {
            ChallengeCircle(text: "você conseguiu!", size: .small)
                .padding(.bottom, 20)
            
            Text(challengeTitle)
                .font(.system(size: 22, weight: .bold))
                .padding(.top, 20)
            
            Text(challengeDescription)
                .font(.system(size: 16))
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, 10)
            
        //CHANGE: trocar pelo nome real
            Text("nome do app")
                .font(.system(size: 12, weight: .medium))
                .padding(.top, 24)
        }
        .frame(maxWidth: 260)
        .multilineTextAlignment(.center)
        .foregroundStyle(challengePhoto != nil ? .white : .black)
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
                }
                .clipped()
                .overlay(Color.black.opacity(0.4))   // camada preta de 40% sobre a foto
        } else {
            Color.white
        }
    }

}

// MARK: - Previews

#Preview("Story 1 - sem foto") {
    StoryCard(
        challengeTitle: "menos distração, mais foco",
        challengeDescription: "sem redes sociais, seu cardio vira um momento para cuidar do corpo e desacelerar a mente."
    )
}

#Preview("Story 2 - com foto") {
    StoryCard( 
        challengeTitle: "menos distração, mais foco",
        challengeDescription: "sem redes sociais, seu cardio vira um momento para cuidar do corpo e desacelerar a mente.",
        challengePhoto: UIImage(named: "test")
    )
}

