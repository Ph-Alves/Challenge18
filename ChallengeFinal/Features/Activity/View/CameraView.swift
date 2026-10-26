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
/// - Lê da Store só o que muda de aparência (ícone do flash, mensagem de erro).
/// - Repassa todos os toques para o Interactor. Não decide nada.
///
/// Quem abre e fecha esta tela é a `ActivityView`, pela `.fullScreenCover`
/// ligada a `store.isCameraPresented`.
struct CameraView: View {

    let interactor: any ActivityInteractorProtocol
    let store: ActivityStore
    let preview: CameraPreviewView

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
            interactor.didSelectFromGallery(newItem)
            galleryItem = nil
        }
        // Erros que acontecem COM a câmera aberta (ex.: falha na captura).
        // Precisa estar aqui porque um alerta da ActivityView, que está
        // por baixo, não aparece enquanto esta tela cobre tudo.
        .alert("Ops!", isPresented: isErrorAlertPresented) {
            Button("OK", role: .cancel) {
                interactor.dismissAlerts()
            }
        } message: {
            Text(store.errorMessage ?? "")
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
                interactor.closeCamera()
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
            // Flash: o ícone vem da Store (o Presenter decide qual mostrar).
            Button {
                interactor.toggleFlash()
            } label: {
                Image(systemName: store.cameraFlashIcon)
                    .font(.system(size: 24))
                    .foregroundStyle(.white)
                    .frame(width: 56, height: 56)
            }
            .accessibilityLabel("Flash")

            Spacer()

            // Disparo: círculo branco com um anel por dentro, como no protótipo.
            Button {
                interactor.takePhoto()
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
                interactor.switchCamera()
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

    /// Mesmo padrão da ActivityView: lê a Store e, ao fechar, avisa o Interactor.
    private var isErrorAlertPresented: Binding<Bool> {
        Binding(
            get: { store.errorMessage != nil },
            set: { isPresented in
                if !isPresented { interactor.dismissAlerts() }
            }
        )
    }
}
