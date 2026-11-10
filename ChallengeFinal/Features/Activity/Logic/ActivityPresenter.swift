//
//  ChallengePresenter.swift
//  ChallengeFinal
//
//  Created by Raquel Souza on 19/10/26.
//

import Foundation
import SwiftUI

// MARK: - Protocol
/// O que o Interactor enxerga do Presenter.
///
/// Com o protocolo, nos testes do Interactor dá para usar um *spy*
/// (um Presenter falso que só anota o que foi chamado), sem Store nem View.
protocol ActivityPresenterProtocol: AnyObject {
    // MARK: -  Step do cronometro
    func presentTime(_ elapsed: TimeInterval)
    
    // MARK: Steps .draw e .challenge
    func presentActivity(_ challenge: FrictionChallenge)
    func presentSearching()
    func presentSearchFailed()
    func presentAcceptedActivity()
    func presentStartAgain()
    func presentMood()
    func presentPhoto()
    func presentRestoredChallenge(title: String, subtitle: String, description: String)

    //MARK: Step .mood
    func presentHumor(_ humor: Humor)
    
    // MARK: Step .photo
    func presentCamera()
    func presentCameraClosed()
    func presentPermissionDenied()
    func presentCaptured(_ data: Data)
    func presentFlash(isOn: Bool)
    func presentError(_ error: Error)
    func presentAlertsDismissed()
    
    // MARK: Step .summary
    func presentStory(_ result: ActivityResult, title: String?, subtitle: String?, description: String?, challengeIcon: String)
    func presentShareSheet(fileURL: URL)
    func presentShareFinished(completed: Bool)
    
    // MARK: Navigation
    func presentSummary(achievement: Achievement)
    func presentFlowFinished()
    func presentInProgress()
    func presentActivityStep()
    func presentDraw()
}

// MARK: - Class
/// O "tradutor" do fluxo de Activity.
///
/// Recebe dados crus do Interactor (`Data`, `Bool`, `Error`), transforma em
/// coisas prontas para a tela (`Image`, textos, ícones) e entrega para a Store
/// pelos métodos `display...`.
///
/// Regras:
/// - Não chama Interactor, Worker nem Coordinator.
/// - Não decide regra de negócio (isso é do Interactor), só COMO mostrar.
/// - Só conhece a Store pelo `ActivityStoreProtocol`.
@MainActor
final class ActivityPresenter: ActivityPresenterProtocol {
    
    // MARK: - Variables
    weak var store: ActivityStoreProtocol?
    
    // MARK: - Init
    init(store: ActivityStoreProtocol) {
        self.store = store
    }
    
    // MARK: - Functions
    
    //MARK: Step .mood
    /// O humor mudou na roleta: a Store atualiza e a roleta gira até ele.
    func presentHumor(_ humor: Humor) {
        store?.displayHumor(humor)
    }
    
    // MARK: Step .photo

    /// Permissão OK: abre a tela da câmera.
    func presentCamera() {
        store?.displayPermissionAlert(nil)
        store?.displayError(nil)
        store?.displayCamera(isPresented: true)
    }

    /// Fecha a tela da câmera (cancelou ou terminou).
    func presentCameraClosed() {
        store?.displayCamera(isPresented: false)
    }

    /// Permissão negada: a câmera não abre e mostramos o alerta.
    func presentPermissionDenied() {
        store?.displayCamera(isPresented: false)
        store?.displayPermissionAlert(
            "Para tirar sua foto, libere o acesso à câmera nos Ajustes. Você também pode importar da galeria ou continuar sem foto."
        )
    }

    /// Chegou uma foto (da câmera ou da galeria).
    ///
    /// `Data` (bytes) -> `UIImage` -> `Image` (SwiftUI),
    /// e os textos dos botões passam para o estado "com foto".
    func presentCaptured(_ data: Data) {
        guard let uiImage = UIImage(data: data) else {
            // Os bytes não formam uma imagem válida.
            store?.displayCamera(isPresented: false)
            store?.displayError("Não foi possível carregar a foto. Tente novamente.")
            return
        }
        store?.displayPhoto(Image(uiImage: uiImage))
        store?.displayError(nil)
        store?.displayCamera(isPresented: false)
    }

    /// Atualiza o ícone do botão de flash na câmera.
    func presentFlash(isOn: Bool) {
        store?.displayFlashIcon(isOn ? "bolt.fill" : "bolt.slash")
    }

    /// Transforma um erro técnico numa mensagem para o usuário.
    /// O Interactor só repassa o erro; escolher o texto é papel do Presenter.
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

        store?.displayError(message)
    }

    /// O usuário fechou o alerta (de permissão ou de erro).
    func presentAlertsDismissed() {
        store?.displayPermissionAlert(nil)
        store?.displayError(nil)
    }
    
    // MARK: - Step do cronometro
    /// Recebe o tempo em segundos e entrega o texto "hh:mm:ss" para a Store.
    /// Formatar é papel do Presenter: o Interactor nunca monta texto de tela.
    /// Ex.: 3725s = 1h 02min 05s -> "01:02:05" (`%02d` completa com zero à esquerda).
    func presentTime(_ elapsed: TimeInterval) {
        let total = Int(elapsed)
        let hours = total / 3600
        let minutes = (total % 3600) / 60
        let seconds = total % 60
        store?.displayTimer(String(format: "%02d:%02d:%02d", hours, minutes, seconds))
    }
    
    // MARK: Steps .draw e .challenge
    // Os requisitos estão declarados no `ActivityPresenterProtocol`.

    /// O sorteio terminou: entrega o desafio para a Store mostrar.
    func presentActivity(_ challenge: FrictionChallenge) {
        store?.displayActivity(challenge)
    }

    /// Começou a procurar: a tela troca os textos para "procurando...".
    func presentSearching() {
        store?.displaySearching()
    }

    /// O sorteio falhou: a tela volta ao estado de espera para tentar de novo.
    func presentSearchFailed() {
        store?.displaySearchFailed()
    }

    /// O usuário aceitou: o step continua `.challenge`, mas passa a mostrar
    /// a tela de desafio aceito (não é uma troca de step).
    func presentAcceptedActivity() {
        store?.displayAcceptedActivity()
    }

    // MARK: Step .summary
    // Tela "desafio finalizado" e compartilhamento.
    // Renderizar é papel do Presenter porque é transformar dados em algo "pronto para exibir"

    /// Monta a imagem do story a partir do resultado.
    ///
    /// Funciona com um resultado recém-criado no fluxo OU com um já salvo
    /// no banco (ex.: futura tela de histórico), porque só lê o `ActivityResult`.
    func presentStory(_ result: ActivityResult, title: String?, subtitle: String?, description: String?, challengeIcon: String) {
        // TODO: o story ainda usa o nome e a descrição do DESAFIO (`activity.name`), enquanto o
        // summary na tela mostra a CONQUISTA. Trocar por `result.achievementTitle` e
        // `result.achievementDescription` para o story compartilhado ficar igual ao summary.
        let title = Self.title(for: result)

        // Bytes -> UIImage no tamanho original: é o fundo inteiro do story.
        let photo = result.photo.flatMap { UIImage(data: $0) }

        let story = StoryCard(
            challengeTitle: title,
            challengeDescription: Self.description(for: result),
            challengePhoto: photo, challengeIcon: challengeIcon
        )

        store?.displayStoryImage(ShareImageRenderer.render(story))
    }

    /// O arquivo do story está pronto: abre o share sheet.
    func presentShareSheet(fileURL: URL) {
        store?.displayError(nil)
        store?.displayShareSheet(ShareItem(activityItems: [fileURL]))
    }

    /// O share sheet fechou (concluiu ou cancelou).
    func presentShareFinished(completed: Bool) {
        store?.displayShareSheet(nil)
    }

    // MARK: Navigation
    // Não há o que formatar: só traduz "apresentar X" em "transicionar para X" na Store.

    /// Abre o summary levando a conquista (título e descrição) para a Store, que a View lê.
    func presentSummary(achievement: Achievement) {
        store?.transitionToSummary(achievement: achievement)
    }

    func presentFlowFinished() {
        store?.finishFlow()
    }

    func presentInProgress() {
        store?.transitionToInProgress()
    }

    func presentActivityStep() {
        store?.transitionToActivity()
    }

    func presentDraw() {
        store?.transitionToDraw()
    }

    /// Volta para o sorteio limpando o desafio anterior.
    func presentStartAgain() {
        store?.transitionToStart()
    }

    func presentMood() {
        store?.transitionToMood()
    }

    func presentPhoto() {
        store?.transitionToPhoto()
    }

    /// O app foi relançado no meio do fluxo: devolve à Store os textos do desafio.
    func presentRestoredChallenge(title: String, subtitle: String, description: String) {
        store?.displayRestoredChallenge(title: title, subtitle: subtitle, description: description)
    }

    // MARK: - Textos (.summary)

    /// Nome da atividade ou um texto padrão se a atividade não tiver nome.
    private static func title(for result: ActivityResult) -> String {
        let name = result.activity?.name.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return name.isEmpty ? "desafio concluído" : name
    }

    /// Descrição da atividade (vazia se não houver).
    private static func description(for result: ActivityResult) -> String {
        result.activity?.activityDescription.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
    }
}
