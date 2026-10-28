//
//  ShareWorker.swift
//  ChallengeFinal
//
//  Created by Raquel Souza on 27/10/26.
//

/// Prepara a imagem do story para o share sheet.
/// Não conhece SwiftUI, a cena nem o `ActivityResult`: recebe uma `UIImage` pronta.

import UIKit

// MARK: - Erros

/// Falhas ao preparar o compartilhamento.
enum ShareError: Error {
    /// O template SwiftUI não virou imagem (o `ImageRenderer` devolveu `nil`).
    case renderFailed
    /// A imagem não pôde ser convertida para PNG.
    case encodingFailed
}

// MARK: - Protocolo

/// Contrato que o Interactor enxerga. Pelo protocolo, para dar mock nos testes.
protocol ShareWorkerProtocol: AnyObject {

    /// Grava a imagem como PNG num arquivo temporário e devolve a URL,
    /// que é o item entregue ao `UIActivityViewController`.
    func makeShareFile(from image: UIImage) throws -> URL
}

// MARK: - Implementação

final class ShareWorker: ShareWorkerProtocol {

    /// Nome do arquivo que aparece no share sheet.
    // CHANGE: colocar um nome legal ou o nome do app
    private let fileName = "Desafio-Concluído"

    deinit {
        print("ShareWorker liberado")
    }

    func makeShareFile(from image: UIImage) throws -> URL {
        guard let data = image.pngData() else {
            throw ShareError.encodingFailed
        }

        // Sempre o mesmo arquivo
        ///cada compartilhamento sobrescreve o anterior, então a pasta temporária não acumula imagens.
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent(fileName)
            .appendingPathExtension("png")

        try data.write(to: url, options: .atomic)
        return url
    }
}
