//
//  CameraView.swift
//  ChallengeFinal
//
//  Created by Raquel Souza on 26/10/26.
//

import SwiftUI
import PhotosUI

/// Tela da câmera em tela cheia (a tela preta do protótipo).
///
/// - Mostra o vídeo ao vivo pela `CameraPreviewView`.
/// - Recebe só dados prontos (ícone do flash, mensagem de erro) e closures.
/// - Não conhece Store nem Interactor: repassa os toques por closures e não decide nada.
///   Por isso serve para qualquer fluxo (Activity, Feelings...).
///
/// Quem abre e fecha esta tela é a view que a usa, pela `.fullScreenCover`.
struct CameraView: View {

    let preview: CameraPreview

    /// Nome do SF Symbol do botão de flash.
    let flashIcon: String

    /// Mensagem do alerta de erro. `nil` = sem alerta.
    let errorMessage: String?

    let closeCamera: () -> Void
    let toggleFlash: () -> Void
    let takePhoto: () -> Void
    let switchCamera: () -> Void
    let didSelectFromGallery: (PhotosPickerItem) -> Void
    let dismissAlerts: () -> Void

    /// Item escolhido no "da biblioteca". Estado só de UI:
    /// assim que chega, repassamos ao Interactor e limpamos.
    @State private var galleryItem: PhotosPickerItem?

    var body: some View {
        ZStack {
            // Fundo preto enquanto a câmera liga.
            Color.black
                .ignoresSafeArea()

            // O vídeo ao vivo ocupando a tela toda.
            preview
                .ignoresSafeArea()

            VStack(spacing: 0) {
                topBar

                Spacer()

                controls
                    .padding(.bottom, 48)

                libraryButton
                    .padding(.bottom, 24)
            }
            .padding(.horizontal, 24)
        }
        // Foto escolhida na biblioteca: segue o mesmo caminho da galeria da outra tela.
        .onChange(of: galleryItem) { _, newItem in
            guard let newItem else { return }
            didSelectFromGallery(newItem)
            galleryItem = nil
        }
        // Erros que acontecem COM a câmera aberta (ex.: falha na captura).
        // Precisa estar aqui porque um alerta da ActivityView, que está
        // por baixo, não aparece enquanto esta tela cobre tudo.
        .alert("Ops!", isPresented: isErrorAlertPresented) {
            Button("OK", role: .cancel) {
                dismissAlerts()
            }
        } message: {
            Text(errorMessage ?? "")
        }
        // A barra de status branca combina com o fundo preto.
        .preferredColorScheme(.dark)
    }

    // MARK: - Barra de cima

    /// Botão de fechar.
    /// ⚠️ Não está no protótipo, mas a `fullScreenCover` não fecha com gesto:
    /// sem ele, o usuário fica preso na câmera. Vale alinhar com o design.
    private var topBar: some View {
        HStack {
            Button {
                closeCamera()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 44, height: 44)
            }
            .accessibilityLabel("Fechar câmera")

            Spacer()
        }
    }

    // MARK: - Controles (flash, disparo, trocar)

    private var controls: some View {
        HStack {
            // Flash: o ícone vem pronto de fora (o Presenter decide qual mostrar).
            Button {
                toggleFlash()
            } label: {
                Image(systemName: flashIcon)
                    .font(.system(size: 24))
                    .foregroundStyle(.white)
                    .frame(width: 56, height: 56)
            }
            .accessibilityLabel("Flash")

            Spacer()

            // Disparo: círculo branco com um anel por dentro, como no protótipo.
            Button {
                takePhoto()
            } label: {
                ZStack {
                    Circle()
                        .fill(.white)
                        .frame(width: 68, height: 68)
                    Circle()
                        .stroke(.black, lineWidth: 2)
                        .frame(width: 52, height: 52)
                }
            }
            .accessibilityLabel("Tirar foto")

            Spacer()

            // Trocar câmera: ícone fixo, então nada na Store.
            Button {
                switchCamera()
            } label: {
                Image(systemName: "arrow.triangle.2.circlepath")
                    .font(.system(size: 24))
                    .foregroundStyle(.white)
                    .frame(width: 56, height: 56)
            }
            .accessibilityLabel("Trocar câmera")
        }
        .padding(.horizontal, 28)
    }

    // MARK: - Biblioteca

    private var libraryButton: some View {
        HStack {
            PhotosPicker(selection: $galleryItem, matching: .images) {
                Label("da biblioteca", systemImage: "photo")
                    .font(.system(size: 15))
                    .foregroundStyle(.white)
            }

            Spacer()
        }
    }

    // MARK: - Alerta

    /// Lê a mensagem e, ao fechar o alerta, avisa quem usa a tela.
    private var isErrorAlertPresented: Binding<Bool> {
        Binding(
            get: { errorMessage != nil },
            set: { isPresented in
                if !isPresented { dismissAlerts() }
            }
        )
    }
}
