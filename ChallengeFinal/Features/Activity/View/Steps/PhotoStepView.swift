//
//  PhotoStepView.swift
//  ChallengeFinal
//
//  Created by Raquel Souza on 23/10/26.
//

import SwiftUI
import PhotosUI

// MARK: - View
//
// O `PhotoStepViewModel` (o que esta tela mostra) fica no `ActivityStore.swift`,
// junto da Store, que é quem guarda esse estado.
//
// O card da foto (`PhotoCard`) e os botões (`CustomButtonComponent`)
// ficam em `Components/`, para o resto do app reaproveitar.

/// Step `.photo` do fluxo de Activity (telas "sorria! você será fotografado").
///
/// Ela não conhece o Interactor nem a Store diretamente: recebe o que mostrar
/// (`viewModel`) e avisa os toques por closures. Quem liga as closures ao
/// Interactor é a `ActivityView` (o container dos steps).
///
/// Vantagem: dá para ver no `#Preview` e mexer no layout sem ter
/// Interactor, Presenter ou câmera prontos.
struct PhotoStepView: View {

    let viewModel: PhotoStepViewModel

    /// Toque em "tire uma foto!" / "tirar outra foto".
    let onTakePhoto: () -> Void
    /// O usuário escolheu uma foto na galeria.
    let onGalleryItemSelected: (PhotosPickerItem) -> Void
    /// Toque em "continuar" / "continuar sem foto".
    let onContinue: () -> Void

    /// Item escolhido no PhotosPicker. É estado só de UI: assim que chega,
    /// repassamos pela closure e limpamos.
    @State private var galleryItem: PhotosPickerItem?

    /// Abre/fecha a galeria. 
    @State private var isShowingGallery = false

    var body: some View {
        VStack(spacing: 0) {
            header
                .padding(.top, 72)

            PhotoCard(photo: viewModel.photo)
                // O botão de câmera fica "encaixado" na borda de baixo do card.
                .overlay(alignment: .bottom) {
                    CustomButtonComponent(
                        title: viewModel.captureButtonTitle,
                        icon: viewModel.captureButtonIcon,
                        type: .secondary,
                        action: onTakePhoto
                    )
                    .offset(y: 1)
                }
                .padding(.top, 28)

            galleryButton
                .padding(.top, 10)

            Spacer()

            continueButton
                .padding(.horizontal, 100) //gambiarra para deixar a width menor, CHANGE esse botao para sumir esses magic numbers.
                .padding(.bottom, 60)
        }
        .padding(.horizontal, 48)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)
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

    // MARK: Título

    private var header: some View {
        VStack(spacing: 16) {
            Text("sorria! você será\nfotografado :)")
                .font(.system(size: 28, weight: .bold))

            Text("fotos ajudam a recordar mais\num desafio completo, tire a sua")
                .font(.system(size: 15))
        }
        .multilineTextAlignment(.center)
        .foregroundStyle(.black)
    }

    // MARK: Botões

    private var galleryButton: some View {
        CustomButtonComponent(
            title: "importar da galeria",
            icon: "photo.fill",
            type: .secondary,
            action: { isShowingGallery = true }
        )
    }

    private var continueButton: some View {
        
        CustomButtonComponent(
            title: viewModel.continueButtonTitle,
            icon: nil,
            type: .secondary,
            action: onContinue)
    }
}

// MARK: - Previews

#Preview("Sem foto") {
    PhotoStepView(
        viewModel: .empty,
        onTakePhoto: { print("tirar foto") },
        onGalleryItemSelected: { _ in print("galeria") },
        onContinue: { print("continuar") }
    )
}

#Preview("Com foto") {
    PhotoStepView(
        viewModel: PhotoStepViewModel(
            photo: Image(systemName: "person.crop.square.fill"), // só para visualizar
            captureButtonTitle: "tirar outra foto",
            captureButtonIcon: "arrow.clockwise",
            continueButtonTitle: "continuar"
        ),
        onTakePhoto: { print("tirar outra") },
        onGalleryItemSelected: { _ in print("galeria") },
        onContinue: { print("continuar") }
    )
}
