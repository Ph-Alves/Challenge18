//
//  FeelingsSummaryView.swift
//  ChallengeFinal
//
//  Tela de resumo: card central arrastável entre "top emoções" e "top grupos".
//

import SwiftUI

struct FeelingsView: View {
    
    let interactor: FeelingsInteractorProtocol
    @State var store: FeelingsStore

    var body: some View {
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
