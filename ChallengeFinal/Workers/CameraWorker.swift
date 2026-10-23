//
//  CameraWorker.swift
//  ChallengeFinal
//
//  Created by Raquel Souza on 20/10/26.
//

///Nesse arquivo, eu checo e peço permissão, configuro a sessão (uma vez só), inicio e paro a sessão, troco entre câmera frontal e traseira, capturo com ou sem flash e devolvo Data.

import AVFoundation

// MARK: - Permissão

/// Situação da permissão de câmera, traduzida do sistema para o nosso domínio.
/// O Interactor só conhece este enum, nunca o `AVAuthorizationStatus` da Apple.
enum CameraPermission: Equatable {
    /// O usuário permitiu o uso da câmera.
    case authorized
    /// O usuário negou, ou a câmera está bloqueada (ex.: controle parental).
    case denied
    /// O usuário ainda não foi perguntado.
    case notDetermined
}

// MARK: - Erros

/// Falhas que podem acontecer ao usar a câmera.
/// Erros são lançados com `throw` e chegam até o Interactor, que decide o que mostrar ao usuário.
enum CameraError: Error {
    /// O aparelho não tem a câmera pedida (ex: simulador).
    case deviceUnavailable
    /// Não foi possível montar ou alterar a sessão de captura.
    case configurationFailed
    /// A captura terminou sem devolver uma imagem.
    case captureFailed
    /// Já existe uma captura em andamento (ex.: toque duplo no botão).
    case captureInProgress
    /// Tentou fotografar com a sessão parada.
    case sessionNotRunning
}

// MARK: - Protocolo

/// Contrato que o Interactor enxerga.
///
/// As operações demoradas avisam o resultado por *completion handler*  (sem async/await).
///
/// Todas as completions são chamadas na MAIN THREAD, então o Interactor
/// pode atualizar o Presenter direto, sem se preocupar com filas.
///
/// O resultado vem como `Result`. No Interactor, use `try result.get()`
/// dentro de um `do/catch`: assim os erros são tratados com `throw`.
protocol CameraWorking: AnyObject {
    
    /// Consulta a permissão atual, sem mostrar nada ao usuário.
    func permissionStatus() -> CameraPermission

    /// Mostra o pedido de permissão do sistema e devolve a resposta do usuário.
    func requestPermission(completion: @escaping (Bool) -> Void)

    /// Configura a sessão (só na primeira vez) e começa a receber imagens da câmera.
    func startSession(completion: @escaping (Result<Void, Error>) -> Void)

    /// Para a câmera. Chame ao sair da tela de câmera para economizar bateria.
    func stopSession()

    /// Alterna entre câmera frontal e traseira.
    func switchCamera(completion: @escaping (Result<Void, Error>) -> Void)

    /// Tira a foto e devolve os bytes da imagem.
    func capturePhoto(flash: Bool, completion: @escaping (Result<Data, Error>) -> Void)
}

// MARK: - Implementação

/// Implementação real da câmera usando AVFoundation.
///
/// o estado da tela fica na `ActivityStore`. O worker só executa e devolve resultados.
///

final class CameraWorker: NSObject, CameraWorking {

    // MARK: Propriedades

    /// A sessão de captura: liga a câmera às saídas (preview e foto).
    /// Fica pública na classe, mas fora do protocolo: só o Builder a acessa,
    /// para entregá-la ao `CameraPreviewView`. O Interactor nunca a vê.
    let session = AVCaptureSession()

    ///Saída responsável por tirar fotos.
    private let photoOutput = AVCapturePhotoOutput()

    /// Entrada atual (a câmera em uso). Guardada para poder trocar de câmera.
    private var currentInput: AVCaptureDeviceInput?

    /// Fila para mexer na sessão fora da main thread.
    private let sessionQueue = DispatchQueue(label: "com.challengefinal.camera.session")

    ///Começa na frontal porque a tela é de selfie .
    private var position: AVCaptureDevice.Position = .front

    /// Impede que a sessão seja configurada duas vezes.
    private var isConfigured = false

    /// Guarda quem está esperando a foto até o delegate entregá-la.
    /// Também serve para bloquear toque duplo: se não for `nil`, já tem captura em andamento.
    private var photoCompletion: ((Result<Data, Error>) -> Void)?

    deinit {
        print("CameraWorker liberado")
    }

    // MARK: Permissão

    func permissionStatus() -> CameraPermission {
        // Mesmo switch do `checkAuthorization()`, mas só traduz o status.
        // Quem decide o que fazer com ele é o Interactor.
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            return .authorized
        case .notDetermined:
            return .notDetermined
        case .denied, .restricted:
            return .denied
        @unknown default:
            return .denied
        }
    }

    func requestPermission(completion: @escaping (Bool) -> Void) {
        // O sistema responde numa fila qualquer, então voltamos para a main.
        AVCaptureDevice.requestAccess(for: .video) { granted in
            DispatchQueue.main.async {
                completion(granted)
            }
        }
    }

    
    // MARK: Sessão

    func startSession(completion: @escaping (Result<Void, Error>) -> Void) {
        // Configurar e iniciar a sessão é demorado: roda na `sessionQueue`.
        sessionQueue.async { [weak self] in
            guard let self = self else { return }

            do {
                // Configura só na primeira vez.
                if !self.isConfigured {
                    try self.configureSession()
                }

                // `startRunning()` é bloqueante, por isso fica fora da main.
                if !self.session.isRunning {
                    self.session.startRunning()
                }

                DispatchQueue.main.async {
                    completion(.success(()))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }

    func stopSession() {
        // Paramos a sessão para economizar bateria quando a câmera fecha (após a foto, ao cancelar, ao sair da tela).
        sessionQueue.async { [weak self] in
            guard let self = self else { return }

            if self.session.isRunning {
                self.session.stopRunning()
            }
        }
    }
    
    //função para trocar câmera frontal e traseira.

    func switchCamera(completion: @escaping (Result<Void, Error>) -> Void) {
        sessionQueue.async { [weak self] in
            guard let self = self else { return }

            do {
                guard let oldInput = self.currentInput else {
                    throw CameraError.configurationFailed
                }

                let newPosition: AVCaptureDevice.Position = (self.position == .front) ? .back : .front

                // Cria o input novo ANTES de remover o antigo.
                // Se o aparelho não tiver a outra câmera, falha aqui e nada muda.
                let newInput = try self.makeInput(for: newPosition)

                // Agrupa as mudanças para o preview não piscar.
                self.session.beginConfiguration()
                defer { self.session.commitConfiguration() }

                self.session.removeInput(oldInput)

                guard self.session.canAddInput(newInput) else {
                    // Se não der para usar a nova, recoloca a antiga para a tela não ficar preta.
                    self.session.addInput(oldInput)
                    throw CameraError.configurationFailed
                }

                self.session.addInput(newInput)
                self.currentInput = newInput
                self.position = newPosition

                DispatchQueue.main.async {
                    completion(.success(()))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }

    // MARK: Captura

    func capturePhoto(flash: Bool, completion: @escaping (Result<Data, Error>) -> Void) {
        
        sessionQueue.async { [weak self] in
            guard let self = self else { return }

            // Proteção contra toque duplo no disparo.
            guard self.photoCompletion == nil else {
                DispatchQueue.main.async {
                    completion(.failure(CameraError.captureInProgress))
                }
                return
            }

            // Não dá para fotografar com a câmera desligada.
            guard self.session.isRunning else {
                DispatchQueue.main.async {
                    completion(.failure(CameraError.sessionNotRunning))
                }
                return
            }

            // Configura a foto.
            let settings = AVCapturePhotoSettings()

            //Aplica o flash caso ele seja suportado.
            if flash && self.photoOutput.supportedFlashModes.contains(.on) {
                settings.flashMode = .on
            }

            // Guarda quem está esperando e manda tirar a foto.
            // O resultado chega no delegate, lá embaixo.
            self.photoCompletion = completion
            self.photoOutput.capturePhoto(with: settings, delegate: self)
        }
    }

    // MARK: Auxiliares privados

    /// Monta a sessão pela primeira vez. Sempre chamado de dentro da `sessionQueue`.
    private func configureSession() throws {
        //Agrupa toda a configuração.
        session.beginConfiguration()
        defer { session.commitConfiguration() }

        // `.photo` é o preset pensado para fotos
        session.sessionPreset = .photo

        // Entrada: a câmera.
        let input = try makeInput(for: position)
        guard session.canAddInput(input) else {
            throw CameraError.configurationFailed
        }
        session.addInput(input)
        currentInput = input

        // Saída: as fotos.
        guard session.canAddOutput(photoOutput) else {
            // Desfaz a entrada, para a próxima tentativa começar do zero.
            session.removeInput(input)
            currentInput = nil
            throw CameraError.configurationFailed
        }
        session.addOutput(photoOutput)

        // Prioriza a qualidade da foto em vez da velocidade de captura.
        photoOutput.maxPhotoQualityPrioritization = .quality

        isConfigured = true
    }

    /// Cria a entrada para a câmera na posição pedida (frontal ou traseira).
    private func makeInput(for position: AVCaptureDevice.Position) throws -> AVCaptureDeviceInput {
        
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: position) else {
            throw CameraError.deviceUnavailable
        }

        do {
            return try AVCaptureDeviceInput(device: device)
        } catch {
            throw CameraError.configurationFailed
        }
    }
}

// MARK: - Delegate de captura

/// AVFoundation avisa que a foto ficou pronta por meio deste delegate.
extension CameraWorker: AVCapturePhotoCaptureDelegate {

    func photoOutput(_ output: AVCapturePhotoOutput,
                     didFinishProcessingPhoto photo: AVCapturePhoto,
                     error: Error?) {
        
        // Transforma a resposta da AVFoundation em sucesso ou falha.
        // Converter para imagem é papel do Presenter, então devolvemos só os bytes.
        
        let result: Result<Data, Error>

        if let error = error {
            result = .failure(error)
        } else if let data = photo.fileDataRepresentation() {
            result = .success(data)
        } else {
            result = .failure(CameraError.captureFailed)
        }

        // Volta para a `sessionQueue` para limpar a `photoCompletion`
        // (é lá que ela é escrita), e depois entrega o resultado na main.
        sessionQueue.async { [weak self] in
            guard let self = self else { return }

            let completion = self.photoCompletion

            // Limpa antes de entregar: libera a próxima captura
            // e garante que a completion seja chamada uma vez só.
            self.photoCompletion = nil

            DispatchQueue.main.async {
                completion?(result)
            }
        }
    }
}
