//
//  ActivityView.swift
//  ChallengeFinal
//
//  Created by Raquel Souza on 19/10/26.
//

import SwiftUI

/// Container do fluxo de Activity: mostra a view do step atual
/// e liga os toques de cada step ao Interactor.
struct ActivityView: View {

    let coordinator: ActivityCoordinator

    // Por que `@State` nas três?
    //
    // O `ActivityBuilder.build` é chamado dentro do `.fullScreenCover` da HomeView,
    // e o SwiftUI pode chamar aquele trecho de novo sempre que a Home redesenha.
    // Cada nova chamada cria Store, Worker, Presenter e Interactor NOVOS.
    //
    // `@State(initialValue:)` só usa o valor da PRIMEIRA vez e ignora os seguintes.
    // Assim, a View fica sempre com o mesmo conjunto (o primeiro), e os três
    // continuam combinando entre si: a `session` mostrada no preview é a do
    // mesmo worker que o Interactor usa.
    @State private var interactor: any ActivityInteractorProtocol
    @State private var store: ActivityStore
    @State private var cameraPreview: CameraPreviewView

    /// Para abrir os Ajustes do iPhone no alerta de permissão.
    @Environment(\.openURL) private var openURL

    init(coordinator: ActivityCoordinator, interactor: any ActivityInteractorProtocol, store: ActivityStore, cameraPreview: CameraPreviewView) {
        self.coordinator = coordinator
        _interactor = State(initialValue: interactor)
        _store = State(initialValue: store)
        _cameraPreview = State(initialValue: cameraPreview)
    }

    var body: some View {
        stepView
            .animation(.default, value: coordinator.step)
            // Permissão de câmera negada.
            .alert("Câmera bloqueada", isPresented: isPermissionAlertPresented) {
                Button("Abrir Ajustes") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        openURL(url)
                    }
                    interactor.dismissAlerts()
                }
                Button("Agora não", role: .cancel) {
                    interactor.dismissAlerts()
                }
            } message: {
                Text(store.permissionAlertMessage ?? "")
            }
            // Erros (falha na captura, câmera indisponível, galeria...).
            .alert("Ops!", isPresented: isErrorAlertPresented) {
                Button("OK", role: .cancel) {
                    interactor.dismissAlerts()
                }
            } message: {
                Text(store.errorMessage ?? "")
            }
            // Tela da câmera: abre e fecha conforme `store.isCameraPresented`.
            .fullScreenCover(isPresented: isCameraPresented) {
                CameraView(interactor: interactor, store: store, preview: cameraPreview)
            }
    }

    // MARK: - Steps

    @ViewBuilder
    private var stepView: some View {
        switch coordinator.step {
        case .photo:
            PhotoStepView(
                viewModel: store.photoStep,
                onTakePhoto: { interactor.openCamera() },
                onGalleryItemSelected: { item in interactor.didSelectFromGallery(item) },
                onContinue: { interactor.continueFromPhoto() }
            )

        // Os outros steps continuam como placeholder até serem implementados
        case .draw:       placeholder("Sortear")
        case .challenge:  placeholder("Desafio")
        case .inProgress: placeholder("Em andamento")
        case .mood:       placeholder("Humor")
        case .summary:    placeholder("Resumo")
        }
    }

    //CHANGE: remover quando todos os steps tiverem as suas views.
    private func placeholder(_ title: String) -> some View {
        VStack(spacing: 24) {
            Text(title)

            Button("Próximo") {
                coordinator.debugNext()
            }
            .buttonStyle(.borderedProminent)
        }
    }

    // MARK: - Câmera

    /// Mesmo padrão dos alertas: lê a Store e, se a tela for fechada,
    /// avisa o Interactor (que para a sessão da câmera).
    private var isCameraPresented: Binding<Bool> {
        Binding(
            get: { store.isCameraPresented },
            set: { isPresented in
                if !isPresented { interactor.closeCamera() }
            }
        )
    }

    // MARK: - Alertas
    //
    // O `.alert` precisa de um Binding<Bool>, mas a View só LÊ a Store.
    // Então o "get" lê a Store, e o "set" (quando o usuário fecha o alerta)
    // avisa o Interactor, que pede ao Presenter para limpar a mensagem.

    private var isPermissionAlertPresented: Binding<Bool> {
        Binding(
            get: { store.permissionAlertMessage != nil },
            set: { isPresented in
                if !isPresented { interactor.dismissAlerts() }
            }
        )
    }

    private var isErrorAlertPresented: Binding<Bool> {
        Binding(
            get: { store.errorMessage != nil },
            set: { isPresented in
                if !isPresented { interactor.dismissAlerts() }
            }
        )
    }
}
