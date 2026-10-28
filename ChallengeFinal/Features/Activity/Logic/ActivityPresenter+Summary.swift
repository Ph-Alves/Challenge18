//
//  ActivityPresenter+Summary.swift
//  ChallengeFinal
//
//  Created by Raquel Souza on 26/10/26.
//

import SwiftUI

// MARK: - Step .summary

/// Tela "desafio finalizado" e compartilhamento.

/// Renderizar é papel do Presenter porque é transformar dados em algo "pronto para exibir"
extension ActivityPresenter {

    /// Monta a imagem do story a partir do resultado.
    ///
    /// Funciona com um resultado recém-criado no fluxo OU com um já salvo
    /// no banco (ex.: futura tela de histórico), porque só lê o `ActivityResult`.
    func presentStory(_ result: ActivityResult, title: String?, subtitle: String?, description: String?) {
        let title = Self.title(for: result)

        // Bytes -> UIImage no tamanho original: é o fundo inteiro do story.
        let photo = result.photo.flatMap { UIImage(data: $0) }

        let story = StoryCard(
            challengeTitle: title,
            challengeDescription: Self.description(for: result),
            challengePhoto: photo
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

    // MARK: - Textos

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
