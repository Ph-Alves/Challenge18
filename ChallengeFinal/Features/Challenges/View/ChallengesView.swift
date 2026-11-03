//
//  ChallengesView.swift
//  ChallengeFinal
//
//  Created by Raquel Souza on 03/11/26.
//

import SwiftUI

struct ChallengesView: View {
    
    //MARK: - Variables
    let interactor: ChallengesInteractorProtocol
    let store: ChallengesStore
    
    /// Texto digitado. Fica na View porque o TextField precisa de binding; a cada mudança, o Interactor recalcula a lista.
    @State private var searchText = ""
    
    private let columns = [
        GridItem(.flexible(), spacing: 28),
        GridItem(.flexible(), spacing: 28)
    ]
    
    //MARK: - View
    var body: some View {
        
    }
    
    
    // MARK: - Título + botão de arquivados
    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 2) {
                Text("desafios")
                    .font(.system(size: 34, weight: .bold))
                    .accessibilityAddTraits(.isHeader)

                Text("desafios que você concluiu")
                    .font(.subheadline)
            }
            .foregroundStyle(.black)

            Spacer()

            CircleIconButton(
                icon: "archivebox",
                action: { interactor.openArchived() }
            )
        }
    }
    
    // MARK: - Filtros
    private var filters: some View {
        HStack(spacing: 8) {
            ForEach(ActivityCategory.allCases, id: \.self) { category in
                CategoryFilterButton(
                    category: category,
                    isSelected: store.selectedCategory == category
                ) {
                    interactor.toggleCategory(category)
                }
            }
        }
    }
    
    // MARK: - Grade ou estado vazio
    @ViewBuilder
    private var content: some View {
        if let emptyState = store.emptyState {
            ChallengesEmptyView(state: emptyState)
        } else {
            LazyVGrid(columns: columns, spacing: 32) {
                ForEach(store.challenges, id: \.activityID) { activity in
                    Button {
                        interactor.openSummary(activity)
                    } label: {
//                        RegisteredActivityCard(
//                            title: activity.name,
//                            humor: activity.result?.humor,
//                            photo: Self.image(from: activity.result?.photo),
//                            placeholderIcon: activity.category.icon
//                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.trailing, 8) // espaço para o selo de humor que sai do card
        }
    }
}
