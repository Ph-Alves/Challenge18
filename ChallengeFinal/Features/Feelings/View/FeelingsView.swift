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
        // O detalhe fecha antes de a câmera abrir e volta depois que ela fecha (`onDismiss`).
        // Os dois ficam aqui, no mesmo nível, porque uma view só apresenta uma coisa por vez.
        .sheet(isPresented: $store.presentDetail, onDismiss: interactor.detailDismissed) {
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
                // Erros com a câmera fechada (ex.: permissão negada).
                .alert("Ops!", isPresented: $store.isErrorPresented) {
                    Button("OK", role: .cancel) {
                        interactor.dismissAlerts()
                    }
                } message: {
                    Text(store.errorMessage ?? "")
                }
                .sheet(item: $store.shareItem) { item in
                    ShareSheet(items: item.activityItems) { completed in
                        interactor.didFinishSharing(completed: completed)
                    }
                    .presentationDetents([.medium, .large])
                    .ignoresSafeArea()
                }
            }
        }
        .fullScreenCover(isPresented: $store.isCameraPresented, onDismiss: interactor.cameraDismissed) {
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
        .onAppear() {
            interactor.loadFeelings()
        }
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
    
    func detailDismissed() {}
    
    func cameraDismissed() {}
    
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
