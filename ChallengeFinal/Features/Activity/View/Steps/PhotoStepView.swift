//
//  PhotoStepView.swift
//  ChallengeFinal
//
//  Created by Raquel Souza on 23/10/26.
//

import SwiftUI
import PhotosUI

// O card da foto (`PhotoCard`) e os botões (`CustomButtonComponent`)
// ficam em `Components/`, para o resto do app reaproveitar.

/// Step `.photo` do fluxo de Activity (telas "sorria! você será fotografado").
///
/// Ela não conhece o Interactor nem a Store diretamente: recebe o que mostrar
/// (`photo`) e avisa os toques por closures. Quem liga as closures ao
/// Interactor é a `ActivityView` (o container dos steps).
///
/// Os textos dos botões dependem só de ter foto ou não, por isso são calculados aqui mesmo.
///
struct PhotoStepView: View {
    @Environment(DesignSystem.self) private var designSystem

    // MARK: - Dados
    /// A foto escolhida (da câmera ou da galeria).
    let photo: Image?
    
    // MARK: - Textos (dependem só de ter foto ou não)
    
    private var hasPhoto: Bool {
        photo != nil
    }

    private var captureButtonTitle: String {
        hasPhoto ? "tirar outra foto" : "tire uma foto!"
    }

    private var continueButtonTitle: String {
        hasPhoto ? "continuar" : "continuar sem foto"
    }
    
    private var title: String {
        hasPhoto ? "ótimo take!" : "sorria! você será\n fotografado :)"
    }
    
    private var description: String {
        hasPhoto ? "mais um desafio, mais uma memória\n pra guardar. bora continuar?" : "fotos ajudam a recordar mais um\n desafio completo, tire a sua!"
    }
    
    private var contentSpacing: CGFloat {
        hasPhoto ? 0 : 120
    }

    // MARK: - Ações (closures)
    
    /// Toque em "tire uma foto!" / "tirar outra foto".
    let onTakePhoto: () -> Void
    
    /// O usuário escolheu uma foto na galeria.
    let onGalleryItemSelected: (PhotosPickerItem) -> Void
    
    /// Toque em "continuar" / "continuar sem foto".
    let onContinue: () -> Void
    
    // MARK: - Estado interno

    /// Item escolhido no PhotosPicker. É estado só de UI: assim que chega, repassamos pela closure e limpamos.
    @State private var galleryItem: PhotosPickerItem?
    /// Abre/fecha a galeria. 
    @State private var isShowingGallery = false

    // MARK: - View
    var body: some View {
        VStack(spacing: contentSpacing) {
            header
            
            content
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        // PhotosPicker não pede permissão: o sistema só entrega a foto escolhida.
        .photosPicker(isPresented: $isShowingGallery, selection: $galleryItem, matching: .images)
        // Quando o usuário escolhe uma foto na galeria, avisa e limpa a seleção,
        // para que escolher a mesma foto de novo também dispare o aviso.
        .onChange(of: galleryItem) { _, newItem in
            guard let newItem else { return }
            onGalleryItemSelected(newItem)
            galleryItem = nil
        }
    }

    // MARK: - Título

    private var header: some View {
        VStack(spacing: 17) {
            if !hasPhoto {
                Image(designSystem.style.icons.camera)
                    .resizable()
                    .frame(width: 145, height: 94.45)
                    .padding(.bottom, 21)
            }
            
            Text(title)
                .font(designSystem.style.typography.title2)
                .multilineTextAlignment(.center)

            Text(description)
                .font(designSystem.style.typography.text2)
                .multilineTextAlignment(.center)
        }
        .multilineTextAlignment(.center)
        .foregroundStyle(designSystem.style.colors.textPrimary)
    }
    
    private var content: some View {
        VStack(spacing: 0) {
            if hasPhoto {
                PhotoCard(photo: photo, height: 282)
                    .padding(.horizontal, 48)
                    .padding(.top, 62)
                    .padding(.bottom, 45)
                
                VStack(spacing: 24) {
                    continueButton
                    takePictureButton
                }
                .padding(.horizontal, 90)
                
            } else {
                VStack(spacing: 24) {
                    takePictureButton
                    
                    galleryButton
                }
                .padding(.horizontal, 90)
                
                continueButton
                    .padding(.horizontal, 90)
                    .padding(.top, 77)
            }
        }
    }

    // MARK: - Botões
    
    private var takePictureButton: some View {
        CustomButtonComponent(
            title: captureButtonTitle,
            icon: hasPhoto ? designSystem.style.icons.retryIcon.base : nil,
            type: hasPhoto ? .secondary : .primary,
            action: onTakePhoto
        )
    }

    private var galleryButton: some View {
        CustomButtonComponent(
            title: "importar da galeria",
            icon: designSystem.style.icons.archivedInvertedChallengeIcon,
            type: .secondary,
            action: { isShowingGallery = true }
        )
    }

    private var continueButton: some View {
        CustomButtonComponent(
            title: continueButtonTitle,
            icon: nil,
            type: hasPhoto ? .primary : .tertiary,
            action: onContinue)
    }
}

// MARK: - Previews

#Preview("Sem foto") {
    PhotoStepView(
        photo: nil,
        onTakePhoto: { print("tirar foto") },
        onGalleryItemSelected: { _ in print("galeria") },
        onContinue: { print("continuar") }
    )
    .environment(DesignSystem.shared)
}

#Preview("Com foto") {
    PhotoStepView(
        photo: Image(systemName: "person.crop.square.fill"),
        onTakePhoto: { print("tirar outra") },
        onGalleryItemSelected: { _ in print("galeria") },
        onContinue: { print("continuar") }
    )
    .environment(DesignSystem.shared)
}
