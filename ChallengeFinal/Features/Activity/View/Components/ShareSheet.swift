//
//  ShareSheet.swift
//  ChallengeFinal
//
//  Created by Raquel Souza on 27/10/26.
//

// Ponte SwiftUI <-> `UIActivityViewController` (o share sheet do iOS). Veio da POC.

import SwiftUI
import UIKit

// MARK: - Item do share sheet

/// O que vai ser compartilhado. É `Identifiable` para abrir com `.sheet(item:)`:
/// a Store guarda um `ShareItem?` e, quando deixa de ser `nil`, o sheet abre.
struct ShareItem: Identifiable {
    let id = UUID()
    let activityItems: [Any]
}

// MARK: - Share sheet

struct ShareSheet: UIViewControllerRepresentable {

    let items: [Any]

    /// `true` = o usuário concluiu (compartilhou/salvou), `false` = cancelou.
    var onFinish: (Bool) -> Void = { _ in }

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: items,
            applicationActivities: nil
        )

        controller.completionWithItemsHandler = { _, completed, _, _ in
            onFinish(completed)
        }

        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
