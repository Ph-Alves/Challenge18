//
//  CameraTestView.swift
//  ChallengeFinal
//
//  Created by Raquel Souza on 23/10/26.
//


//
//  CameraTestView.swift
//  ChallengeFinal
//
//  ⚠️ ARQUIVO TEMPORÁRIO: só para testar o CameraWorker no iPhone.
//  Apague depois que o fluxo VIP (Interactor/Presenter/Store) estiver pronto.
//  Aqui a View fala direto com o worker, o que NÃO é o certo no VIP.
//

import SwiftUI

struct CameraTestView: View {

    /// O worker real. `@State` só para ele não ser recriado a cada redesenho.
    @State private var worker = CameraWorker()

    @State private var capturedImage: UIImage?
    @State private var isFlashOn = false
    @State private var message = "Iniciando..."

    var body: some View {
        ZStack {
            // A câmera ao vivo, ocupando a tela toda.
            CameraPreviewView(session: worker.session)
                .ignoresSafeArea()

            VStack(spacing: 16) {
                // Mensagens de status e erros.
                Text(message)
                    .font(.caption)
                    .foregroundStyle(.white)
                    .padding(8)
                    .background(.black.opacity(0.6), in: .capsule)

                Spacer()

                // Miniatura da última foto tirada.
                if let capturedImage {
                    Image(uiImage: capturedImage)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 160)
                        .clipShape(.rect(cornerRadius: 12))
                }

                HStack(spacing: 32) {
                    Button(isFlashOn ? "Flash ON" : "Flash OFF") {
                        isFlashOn.toggle()
                    }

                    Button("📸 Foto") {
                        worker.capturePhoto(flash: isFlashOn) { result in
                            do {
                                let data = try result.get()
                                capturedImage = UIImage(data: data)
                                message = "Foto: \(data.count / 1024) KB"
                            } catch {
                                message = "Erro na foto: \(error)"
                            }
                        }
                    }

                    Button("🔄 Trocar") {
                        worker.switchCamera { result in
                            do {
                                try result.get()
                                message = "Câmera trocada"
                            } catch {
                                message = "Erro ao trocar: \(error)"
                            }
                        }
                    }
                }
                .buttonStyle(.borderedProminent)
                .padding(.bottom, 32)
            }
            .padding()
        }
        .onAppear {
            startCamera()
        }
        .onDisappear {
            worker.stopSession()
        }
    }

    /// Mesmo fluxo que o Interactor vai fazer depois:
    /// checa a permissão, pede se precisar, e liga a câmera.
    private func startCamera() {
        switch worker.permissionStatus() {
        case .authorized:
            startSession()
        case .notDetermined:
            worker.requestPermission { granted in
                if granted {
                    startSession()
                } else {
                    message = "Permissão negada"
                }
            }
        case .denied:
            message = "Permissão negada. Libere nos Ajustes."
        }
    }

    private func startSession() {
        worker.startSession { result in
            do {
                try result.get()
                message = "Câmera ligada"
            } catch {
                message = "Erro ao ligar: \(error)"
            }
        }
    }
}