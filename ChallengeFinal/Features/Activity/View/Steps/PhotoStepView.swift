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

    var body: some View {
        VStack(spacing: 0) {
            header
                .padding(.top, 72)

            photoCard
                .padding(.top, 28)

            galleryButton
                .padding(.top, 28)

            Spacer()

            continueButton
                .padding(.bottom, 32)
        }
        .padding(.horizontal, 48)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)
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

    // MARK: Card da foto

    /// O card com a foto (ou o fundo pontilhado) e o botão de câmera
    /// "encaixado" na borda de baixo, como no protótipo.
    private var photoCard: some View {
        cardContent
            .frame(maxWidth: .infinity)
            .frame(height: 260)
            .clipShape(.rect(cornerRadius: 32))
            .overlay {
                // Borda só no estado vazio (com foto, o protótipo não tem borda).
                if viewModel.photo == nil {
                    RoundedRectangle(cornerRadius: 32)
                        .stroke(.black, lineWidth: 1)
                }
            }
            // O botão fica por cima da borda de baixo do card.
            .overlay(alignment: .bottom) {
                captureButton
                    .offset(y: 16)
            }
    }

    @ViewBuilder
    private var cardContent: some View {
        if let photo = viewModel.photo {
            photo
                .resizable()
                .scaledToFill() // preenche o card, cortando as sobras
        } else {
            DotGridBackground()
        }
    }

    // MARK: Botões

    private var captureButton: some View {
        Button(action: onTakePhoto) {
            Label(viewModel.captureButtonTitle, systemImage: viewModel.captureButtonIcon)
        }
        .buttonStyle(PhotoActionButtonStyle())
    }

    private var galleryButton: some View {
        // PhotosPicker não pede permissão: o sistema só entrega a foto escolhida.
        PhotosPicker(selection: $galleryItem, matching: .images) {
            Label("importar da galeria", systemImage: "photo.fill")
        }
        .buttonStyle(PhotoActionButtonStyle())
    }

    private var continueButton: some View {
        Button(action: onContinue) {
            Text(viewModel.continueButtonTitle)
                .font(.system(size: 15))
                .foregroundStyle(.black)
                .padding(.horizontal, 14)
                .padding(.vertical, 6)
                .background(Color(white: 0.88), in: .capsule)
        }
    }
}

// MARK: - Estilo dos botões do card

/// Botões cinza de largura total, com ícone + texto em negrito e sombra suave
/// ("tire uma foto!" e "importar da galeria").
///
/// Dica: quando o `DesignSystem.swift` tiver cores e fontes, troque os valores fixos daqui.
private struct PhotoActionButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 15, weight: .semibold))
            .foregroundStyle(.black)
            .frame(maxWidth: .infinity)
            .frame(height: 36)
            .background(Color(white: 0.88), in: .rect(cornerRadius: 12))
            .shadow(color: .black.opacity(0.15), radius: 4, y: 3)
            // Leve feedback ao pressionar.
            .opacity(configuration.isPressed ? 0.7 : 1)
    }
}

// MARK: - Fundo pontilhado

/// O fundo de pontinhos do card vazio.
/// `Canvas` desenha tudo de uma vez, sem criar uma view para cada ponto.
private struct DotGridBackground: View {
    var spacing: CGFloat = 23
    var dotSize: CGFloat = 3

    var body: some View {
        Canvas { context, size in
            var y = spacing / 2
            while y < size.height {
                var x = spacing / 2
                while x < size.width {
                    let dot = CGRect(x: x - dotSize / 2, y: y - dotSize / 2,
                                     width: dotSize, height: dotSize)
                    context.fill(Path(ellipseIn: dot), with: .color(.gray.opacity(0.25)))
                    x += spacing
                }
                y += spacing
            }
        }
        .background(Color.white)
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
