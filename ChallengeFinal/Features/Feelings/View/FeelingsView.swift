//
//  FeelingsSummaryView.swift
//  ChallengeFinal
//
//  Tela de resumo: card central arrastável entre "top emoções" e "top grupos".
//

import SwiftUI
import PhotosUI
import AVFoundation

/// Tela de Feelings. Só lê da Store e repassa as ações ao Interactor.
struct FeelingsView: View {
    
    // MARK: - Variables
    
    /// Pelo protocolo, para dar para passar um Interactor falso no preview.
    let interactor: FeelingsInteractorProtocol
    
    /// Estado da tela (somente leitura aqui).
    @State var store: FeelingsStore
    
    /// Vídeo ao vivo da câmera, usado ao tirar outra foto de uma atividade.
    let cameraPreview: CameraPreview

    // MARK: - Body
    
    var body: some View {
        ScrollView {
            VStack(spacing: 37) {
                // O gráfico recebe só dados e uma closure, sem conhecer Store nem Interactor.
                FeelingsGraphView(feelings: store.feelings, loadAction: interactor.loadFeelings)
                
                // A listagem de atividades de cada categoria
                FeelingsListView(feelings: store.feelings, redirectAction: interactor.selectActivity)
            }
            .padding(.horizontal, 32)
        }
        .scrollIndicators(.hidden)
        .sheet(isPresented: $store.presentDetail) {
            if let activity = store.selectedActivity {
                ActivityDetailView(
                    returnAction: store.returnToFeelings,
                    deleteAction: interactor.deleteActivity,
                    retakeAction: interactor.retakePhoto,
                    shareAction: { interactor.shareStory(store.storyImage) },
                    selected: activity,
                    photo: store.selectedPhoto
                )
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
                // A câmera sai daqui (e não da FeelingsView) porque a sheet já está aberta:
                // uma view não consegue apresentar duas coisas ao mesmo tempo.
                .fullScreenCover(isPresented: isCameraPresented) {
                    CameraView(
                        preview: cameraPreview,
                        flashIcon: store.cameraFlashIcon,
                        errorMessage: store.errorMessage,
                        closeCamera: interactor.closeCamera,
                        toggleFlash: interactor.toggleFlash,
                        takePhoto: interactor.takePhoto,
                        switchCamera: interactor.switchCamera,
                        didSelectFromGallery: interactor.didSelectFromGallery,
                        dismissAlerts: interactor.dismissAlerts
                    )
                }
                // Erros com a câmera fechada (ex.: permissão negada).
                .alert("Ops!", isPresented: isErrorAlertPresented) {
                    Button("OK", role: .cancel) {
                        interactor.dismissAlerts()
                    }
                } message: {
                    Text(store.errorMessage ?? "")
                }
                .sheet(item: shareItem) { item in
                    ShareSheet(items: item.activityItems) { completed in
                        interactor.didFinishSharing(completed: completed)
                    }
                    .presentationDetents([.medium, .large])
                    .ignoresSafeArea()
                }
            }
        }
        .onAppear() {
            interactor.loadFeelings()
        }
    }
}

// MARK: - Bindings

extension FeelingsView {
    
    /// Lê a Store e, se a tela for fechada, avisa o Interactor (que para a sessão da câmera).
    private var isCameraPresented: Binding<Bool> {
        Binding(
            get: { store.isCameraPresented },
            set: { isPresented in
                if !isPresented { interactor.closeCamera() }
            }
        )
    }
    
    /// Lê a Store e, se o usuário fechar o sheet arrastando para baixo, avisa o Interactor (que pede para limpar a Store).
    private var shareItem: Binding<ShareItem?> {
        Binding(
            get: { store.shareItem },
            set: { item in
                if item == nil { interactor.didFinishSharing(completed: false) }
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

/// Interactor falso só para o preview: não busca nada.
private final class FeelingsInteractorPreviewMock: FeelingsInteractorProtocol {
    func retakePhoto() {}
    
    func closeCamera() {}
    
    func toggleFlash() {}
    
    func switchCamera() {}
    
    func takePhoto() {}
    
    func didSelectFromGallery(_ item: PhotosPickerItem) {}
    
    func dismissAlerts() {}
    
    func shareStory(_ image: UIImage?) {}
    
    func didFinishSharing(completed: Bool) {}
    
    func deleteActivity(activity: Activity) {}
    
    func selectActivity(activity: Activity) {}
    
    func loadFeelings() {}
}

#Preview {
    FeelingsView(
        interactor: FeelingsInteractorPreviewMock(),
        store: FeelingsStore(),
        cameraPreview: CameraPreview(session: AVCaptureSession())
    )
}
