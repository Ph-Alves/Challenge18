//
//  ActivityInteractor+Photo.swift
//  ChallengeFinal
//
//  Created by Raquel Souza on 23/10/26.
//

import Foundation
import PhotosUI
import SwiftUI

/// Erro ao carregar uma foto da galeria.
enum PhotoLibraryError: Error {
    /// O item escolhido não devolveu os bytes da imagem.
    case loadFailed
}

// MARK: - Step .photo

/// Ações das telas "sorria! você será fotografado" e da câmera.
///
/// Padrão de todas as ações:
/// 1. Decide o que fazer (regra de negócio).
/// 2. Usa o worker, se precisar.
/// 3. Avisa o Presenter do resultado (nunca mexe na Store direto).
///
/// As completions do worker já chegam na main thread,
/// então dá para chamar o Presenter direto.
extension ActivityInteractor {

    // MARK: Abrir e fechar a câmera

    /// Toque em "tire uma foto!".
    ///
    /// A permissão é verificada AQUI, e não ao abrir o step: quem só quer
    /// importar da galeria ou continuar sem foto nunca vê o pedido de câmera.
    ///
    /// Perguntamos ao worker toda vez (sem guardar a resposta) porque o
    /// usuário pode ter mudado a permissão nos Ajustes no meio do caminho.
    func openCamera() {
        switch camera.permissionStatus() {
        case .authorized:
            startCamera()

        case .notDetermined:
            // Primeira vez: o sistema mostra o pedido de permissão.
            camera.requestPermission { [weak self] granted in
                guard let self else { return }

                if granted {
                    self.startCamera()
                } else {
                    self.presenter.presentPermissionDenied()
                }
            }

        case .denied:
            presenter.presentPermissionDenied()
        }
    }

    /// Toque em "tirar outra foto".
    ///
    /// A foto anterior continua em `selectedPhoto` até chegar uma nova.
    /// Se o usuário fechar a câmera sem fotografar, ele não perde a que tinha.
    func retakePhoto() {
        openCamera()
    }

    /// O usuário fechou a câmera sem tirar foto.
    func closeCamera() {
        camera.stopSession()
        presenter.presentCameraClosed()
    }

    // MARK: Controles da câmera

    /// Toque no botão de flash.
    func toggleFlash() {
        isFlashOn.toggle()
        presenter.presentFlash(isOn: isFlashOn)
    }

    /// Toque no botão de trocar câmera.
    /// Não muda nada na Store: o preview se atualiza sozinho.
    func switchCamera() {
        camera.switchCamera { [weak self] result in
            guard let self else { return }

            do {
                try result.get()
            } catch {
                self.presenter.presentError(error)
            }
        }
    }

    /// Toque no botão de disparo.
    func takePhoto() {
        camera.capturePhoto(flash: isFlashOn) { [weak self] result in
            guard let self else { return }

            do {
                let data = try result.get()
                self.didReceivePhoto(data)
            } catch {
                self.presenter.presentError(error)
            }
        }
    }

    // MARK: Galeria

    /// O usuário escolheu uma foto no PhotosPicker
    /// (pelo "importar da galeria" ou pelo "da biblioteca" na câmera).
    ///
    /// O picker devolve só uma "referência" (`PhotosPickerItem`).
    /// Os bytes precisam ser carregados, o que pode demorar (ex.: foto no iCloud).
    ///
    /// TODO(refatoração): mover o carregamento para um worker de galeria,
    /// assim o Interactor não precisa importar PhotosUI.
    func didSelectFromGallery(_ item: PhotosPickerItem) {
        _ = item.loadTransferable(type: Data.self) { [weak self] result in
            // O sistema responde numa fila qualquer: voltamos para a main.
            DispatchQueue.main.async {
                guard let self else { return }

                do {
                    guard let data = try result.get() else {
                        throw PhotoLibraryError.loadFailed
                    }
                    self.didReceivePhoto(data)
                } catch {
                    self.presenter.presentError(error)
                }
            }
        }
    }

    // MARK: Continuar e alertas

    /// Toque em "continuar" ou "continuar sem foto".
    ///
    /// A foto (ou `nil`) fica guardada em `selectedPhoto` para o resumo
    /// e para o `ActivityResult` no final do fluxo.
    func continueFromPhoto() {
        camera.stopSession()
        presenter.presentSummary()
    }

    /// O usuário fechou um alerta (permissão negada ou erro).
    func dismissAlerts() {
        presenter.presentAlertsDismissed()
    }

    // MARK: - Auxiliares privados

    /// Permissão OK: abre a tela da câmera e liga a sessão.
    private func startCamera() {
        // Mostra o estado atual do flash e abre a tela.
        // O preview fica preto por um instante até a sessão ligar.
        presenter.presentFlash(isOn: isFlashOn)
        presenter.presentCamera()

        camera.startSession { [weak self] result in
            guard let self else { return }

            do {
                try result.get()
            } catch {
                // A câmera não ligou: fecha a tela e mostra o erro.
                self.camera.stopSession()
                self.presenter.presentCameraClosed()
                self.presenter.presentError(error)
            }
        }
    }

    /// Caminho comum para foto da câmera e da galeria:
    /// daqui pra frente, as duas são iguais.
    private func didReceivePhoto(_ data: Data) {
        selectedPhoto = data
        camera.stopSession()
        presenter.presentCaptured(data)
    }
}
