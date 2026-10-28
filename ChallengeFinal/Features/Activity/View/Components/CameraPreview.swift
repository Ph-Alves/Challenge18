//
//  CameraPreviewView.swift
//  ChallengeFinal
//
//  Created by Raquel Souza on 23/10/26.
//

import SwiftUI
import AVFoundation

// MARK: - CameraPreviewView

/// Mostra ao vivo o que a câmera está vendo.
///
/// O SwiftUI não tem uma view nativa para isso, então usamos um
/// `UIViewRepresentable`: uma "ponte" que coloca uma `UIView` do UIKit
/// dentro de uma tela SwiftUI.
///
/// Ela só recebe a `session` e mostra o vídeo. Não sabe tirar foto, trocar
/// câmera nem nada: isso é papel do worker, chamado pelo Interactor.
struct CameraPreview: UIViewRepresentable {

    /// A sessão do `CameraWorker`. Quem entrega é o Builder.
    let session: AVCaptureSession

    /// Chamado uma vez, quando o SwiftUI cria a view.
    func makeUIView(context: Context) -> PreviewUIView {
        let view = PreviewUIView()

        // Fundo preto enquanto a câmera não liga (evita um flash branco).
        view.backgroundColor = .black

        // Conecta a camada de vídeo à sessão: a partir daqui,
        // tudo que a câmera captura aparece nesta view.
        view.previewLayer.session = session

        // Preenche a tela toda, cortando as bordas se precisar,
        // sem deixar faixas pretas (como a câmera do iPhone).
        view.previewLayer.videoGravity = .resizeAspectFill

        return view
    }

    /// Chamado quando o SwiftUI atualiza a view.
    /// Não precisa fazer nada: a camada se redimensiona sozinha (ver `PreviewUIView`).
    func updateUIView(_ uiView: PreviewUIView, context: Context) { }
}

// MARK: - PreviewUIView

/// Uma `UIView` cuja camada principal JÁ É a camada de vídeo da câmera.
///
final class PreviewUIView: UIView {

    /// Diz ao UIKit: "quando criar esta view, use uma AVCaptureVideoPreviewLayer
    /// como camada principal, e não uma CALayer comum".
    override class var layerClass: AnyClass {
        AVCaptureVideoPreviewLayer.self
    }

    /// Atalho para acessar a camada já com o tipo certo.
    /// O `as!` é seguro aqui porque o `layerClass` garante o tipo.
    var previewLayer: AVCaptureVideoPreviewLayer {
        layer as! AVCaptureVideoPreviewLayer
    }
}
