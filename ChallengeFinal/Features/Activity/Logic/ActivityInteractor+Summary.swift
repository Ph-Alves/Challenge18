//
//  ActivityInteractor+Summary.swift
//  ChallengeFinal
//
//  Created by Raquel Souza on 26/10/26.
//

import SwiftUI

// MARK: - Step .summary

/// Ações da tela "desafio finalizado": gerar o story e compartilhar.
/// O "finalizar" é o `finishActivityFlow()`, no arquivo principal.
///
/// Fluxo do compartilhamento (VIP):
/// 1. `loadSummary(...)` recebe os textos do desafio (a View lê da Store) e
///    manda ao Presenter junto com o resultado. O Presenter renderiza o story
///    e guarda a imagem pronta na Store.
/// 2. Toque em "compartilhar": a View entrega essa imagem em `shareStory(_:)`.
/// 3. O `ShareWorker` grava o PNG; o Presenter abre o share sheet.
/// 4. O share sheet fecha: `didFinishSharing(completed:)`.
extension ActivityInteractor {

    // MARK: Resumo

    /// Chamado quando a tela de resumo aparece: gera a imagem do story.
    ///
    /// Os textos do desafio vêm da View, que os lê da Store
    /// (preenchidos no step `.draw`).
    func loadSummary(title: String?, subtitle: String?, description: String?) {
        presenter.presentStory(
            makeResultIfNeeded(),
            title: title,
            subtitle: subtitle,
            description: description
        )
    }

    // MARK: Compartilhar

    /// Toque em "compartilhar".
    ///
    /// Recebe a imagem que o Presenter já renderizou (está na Store).
    /// `nil` = a renderização falhou: mostramos o erro em vez de abrir um sheet vazio.
    func shareStory(_ image: UIImage?) {
        guard let image else {
            presenter.presentError(ShareError.renderFailed)
            return
        }

        do {
            let fileURL = try share.makeShareFile(from: image)
            presenter.presentShareSheet(fileURL: fileURL)
        } catch {
            presenter.presentError(error)
        }
    }

    /// O share sheet fechou (concluiu ou cancelou).
    func didFinishSharing(completed: Bool) {
        presenter.presentShareFinished(completed: completed)
    }

    // MARK: - Auxiliares privados

    /// Monta o `ActivityResult` com os dados do fluxo (só na primeira vez).
    ///
    /// Guardamos em `result` para que o story e o que for salvo no banco
    /// sejam sempre o MESMO objeto, mesmo se a tela aparecer de novo.
    private func makeResultIfNeeded() -> ActivityResult {
        if let result {
            return result
        }

        let newResult = ActivityResult(
            photo: selectedPhoto,
            time: timerElapsed,
            humor: selectedHumor ?? .chill
        )

        result = newResult
        return newResult
    }
}
