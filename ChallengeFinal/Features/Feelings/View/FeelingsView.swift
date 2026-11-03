//
//  FeelingsSummaryView.swift
//  ChallengeFinal
//
//  Tela de resumo: card central arrastável entre "top emoções" e "top grupos".
//

import SwiftUI

/// Tela de Feelings. Só lê da Store e repassa as ações ao Interactor.
struct FeelingsView: View {
    
    // MARK: - Variables
    
    /// Pelo protocolo, para dar para passar um Interactor falso no preview.
    let interactor: FeelingsInteractorProtocol
    
    /// Estado da tela (somente leitura aqui).
    @State var store: FeelingsStore

    // MARK: - Body
    
    var body: some View {
        // O gráfico recebe só dados e uma closure, sem conhecer Store nem Interactor.
        FeelingsGraphView(feelings: store.feelings, loadAction: interactor.loadFeelings)
    }
}

/// Interactor falso só para o preview: não busca nada.
private final class FeelingsInteractorPreviewMock: FeelingsInteractorProtocol {
    func loadFeelings() {}
}

#Preview {
    FeelingsView(
        interactor: FeelingsInteractorPreviewMock(),
        store: FeelingsStore()
    )
}
