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
                ActivityDetailView(returnAction: store.returnToFeelings, deleteAction: interactor.deleteActivity, selected: activity)
                    .presentationDetents([.large])
                    .presentationDragIndicator(.visible)
            }
        }
    }
}

/// Interactor falso só para o preview: não busca nada.
private final class FeelingsInteractorPreviewMock: FeelingsInteractorProtocol {
    func deleteActivity(activity: Activity) {}
    
    func selectActivity(activity: Activity) {}
    
    func loadFeelings() {}
}

#Preview {
    FeelingsView(
        interactor: FeelingsInteractorPreviewMock(),
        store: FeelingsStore()
    )
}
