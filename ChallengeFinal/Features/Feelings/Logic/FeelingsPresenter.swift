//
//  FeelingsPresenter.swift
//  ChallengeFinal
//
//  Created by Paulo Henrique Costa Alves on 02/11/26.
//

import SwiftUI

// MARK: - Protocol

/// O que o Interactor enxerga do Presenter.
///
/// Com o protocolo, nos testes do Interactor dá para usar um *spy*
/// (um Presenter falso que só anota o que foi chamado), sem Store nem View.
protocol FeelingsPresenterProtocol: AnyObject {
    // MARK: Carregamento
    func presentFeelingsLoaded(activities: [Activity])
    func presentSelectedActivity(activity: Activity)
    // MARK: Câmera
    func presentCamera()
    func presentCameraClosed()
    func presentPermissionDenied()
    func presentPhotoUpdated(_ data: Data)
    func presentFlash(isOn: Bool)
    func presentError(_ error: Error)
    func presentAlertsDismissed()
    func presentDetailVisibility(isVisible: Bool)
    // MARK: Compartilhar
    func presentStory(for activity: Activity)
    func presentShareSheet(fileURL: URL)
    func presentShareFinished(completed: Bool)
}

// MARK: - Class

/// O "tradutor" da tela de Feelings.
///
/// Recebe as Activities cruas do Interactor, organiza por humor e entrega
/// para a Store.
///
/// Regras:
/// - Não chama Interactor, Worker nem Coordinator.
/// - Não decide regra de negócio (isso é do Interactor), só COMO mostrar.
/// - Só conhece a Store pelo `FeelingsStoreProtocol`.
@MainActor
final class FeelingsPresenter: FeelingsPresenterProtocol {
    
    // MARK: - Variables
    
    /// Fraca para não criar ciclo com a Store.
    weak var store: FeelingsStoreProtocol?
    
    // MARK: - Init
    
    init(store: FeelingsStoreProtocol) {
        self.store = store
    }

    // MARK: - Carregamento

    /// Agrupa as Activities por humor (ex.: `.happy` -> [(Activity, Image?), ...]),
    /// que é o formato que o gráfico precisa para contar cada barra. Cada atividade
    /// já vai com a foto convertida, para a lista não processar nada.
    func presentFeelingsLoaded(activities: [Activity]) {
        // Descarta as que não têm humor registrado.
        let withHumor = activities.filter { $0.result?.humor != nil }
        // O `!` é seguro: o filtro acima garante que `result` existe.
        // Uso dicionário aqui por que consigo definir por chave valor e definir os labels
        // Não preciso de ordenação, então mais um motivo para se usar.
        let entries = withHumor.map { (activity: $0, image: image(from: $0.result?.photo)) }
        let grouped = Dictionary(grouping: entries) { $0.activity.result!.humor }
        
        store?.presentFeelingsLoaded(feelings: grouped)
    }
    
    func presentSelectedActivity(activity: Activity) {
        store?.presentActivityDetails(activity: activity, photo: image(from: activity.result?.photo))
        presentStory(for: activity)
    }
    
    /// `Data` (bytes) -> `UIImage` -> `Image` (SwiftUI). `nil` se não houver foto ou os bytes forem inválidos.
    func image(from data: Data?) -> Image? {
        guard let data, let uiImage = UIImage(data: data) else { return nil }
        return Image(uiImage: uiImage)
    }

    // MARK: - Câmera (tirar outra foto)

    /// Permissão OK: abre a tela da câmera.
    func presentCamera() {
        store?.presentError(nil)
        store?.presentCamera(isPresented: true)
    }
    
    /// Fecha a tela da câmera (cancelou ou terminou).
    func presentCameraClosed() {
        store?.presentCamera(isPresented: false)
    }
    
    /// Permissão negada: a câmera não abre e mostramos o alerta.
    func presentPermissionDenied() {
        store?.presentCamera(isPresented: false)
        store?.presentError("Para tirar sua foto, libere o acesso à câmera nos Ajustes. Você também pode importar da galeria.")
    }
    
    /// A foto da atividade foi trocada: mostra a nova e fecha a câmera.
    func presentPhotoUpdated(_ data: Data) {
        guard let photo = image(from: data) else {
            store?.presentCamera(isPresented: false)
            store?.presentError("Não foi possível carregar a foto. Tente novamente.")
            return
        }
        store?.presentPhoto(photo)
        store?.presentError(nil)
        store?.presentCamera(isPresented: false)
    }
    
    /// Atualiza o ícone do botão de flash na câmera.
    func presentFlash(isOn: Bool) {
        store?.presentFlashIcon(isOn ? "bolt.fill" : "bolt.slash")
    }
    
    /// Transforma um erro técnico numa mensagem para o usuário.
    func presentError(_ error: Error) {
        let message: String
        
        switch error {
        case CameraError.deviceUnavailable:
            message = "Não encontramos uma câmera neste aparelho. Você pode importar da galeria."
        case CameraError.captureInProgress:
            // Toque duplo no disparo: não é um problema para o usuário, só ignoramos.
            return
        case CameraError.sessionNotRunning,
             CameraError.configurationFailed:
            message = "A câmera não está pronta. Feche e tente novamente."
        case CameraError.captureFailed:
            message = "Não foi possível tirar a foto. Tente novamente."
        case PhotoLibraryError.loadFailed:
            message = "Não foi possível carregar a foto da galeria. Tente outra."
        case ShareError.renderFailed,
             ShareError.encodingFailed:
            message = "Não foi possível preparar a imagem para compartilhar. Tente novamente."
        default:
            message = "Algo deu errado. Tente novamente."
        }
        
        store?.presentError(message)
    }
    
    /// O usuário fechou o alerta.
    func presentAlertsDismissed() {
        store?.presentError(nil)
    }
    
    /// Esconde ou volta com o sheet de detalhe (ele sai para a câmera abrir e volta depois).
    func presentDetailVisibility(isVisible: Bool) {
        store?.presentDetailVisibility(isVisible: isVisible)
    }

    // MARK: - Compartilhar

    /// Renderiza o story da atividade e guarda a imagem pronta na Store.
    /// Renderizar é papel do Presenter: é transformar dados em algo "pronto para exibir".
    func presentStory(for activity: Activity) {
        let name = activity.name.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Bytes -> UIImage no tamanho original: é o fundo inteiro do story.
        let photo = activity.result?.photo.flatMap { UIImage(data: $0) }
        
        let story = StoryCard(
            challengeTitle: name.isEmpty ? "desafio concluído" : name,
            challengeDescription: activity.activityDescription.trimmingCharacters(in: .whitespacesAndNewlines),
            challengePhoto: photo
        )
        
        store?.presentStoryImage(ShareImageRenderer.render(story))
    }
    
    /// O arquivo do story está pronto: abre o share sheet.
    func presentShareSheet(fileURL: URL) {
        store?.presentError(nil)
        store?.presentShareSheet(ShareItem(activityItems: [fileURL]))
    }
    
    /// O share sheet fechou (concluiu ou cancelou).
    func presentShareFinished(completed: Bool) {
        store?.presentShareSheet(nil)
    }
}
