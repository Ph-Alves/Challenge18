//
//  ArchivedChallengesView.swift
//  ChallengeFinal
//
//  Created by Raquel Souza on 03/11/26.
//

import SwiftUI

// Sheet "desafios arquivados"
struct ArchivedChallengesView: View {

    // MARK: - Variables
    let interactor: ChallengesInteractorProtocol
    var store: ChallengesStore

// MARK: - View
var body: some View {
    NavigationStack {
        ScrollView {
            VStack(spacing: 0) {
                header
                    .padding(.top, 24)

                content
                    .padding(.top, 40)
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 32)
        }
        .background(Color.white)
        .navigationTitle("desafios arquivados")
        .navigationBarTitleDisplayMode(.inline)  
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(role: .close) {
                    interactor.closeArchived()
                }
            }
        }
    }
}
          

    // MARK: - Cabeçalho
    private var header: some View {
        VStack(spacing: 16) {
            Text("mudou de ideia né?")
                .font(.system(size: 28, weight: .bold))

            Text("você pode devolver o desafio para a lista do grupo de onde ele veio")
                .font(.body)
                .fixedSize(horizontal: false, vertical: true)
        }
        .multilineTextAlignment(.center)
        .foregroundStyle(.black)
    }

    // MARK: - Lista ou vazio
    @ViewBuilder
    private var content: some View {
        if let emptyState = store.archivedEmptyState {
            ChallengesEmptyView(state: emptyState)
        } else {
            LazyVStack(spacing: 20) {
                ForEach(store.archivedChallenges, id: \.activityID) { activity in
                    ArchivedChallengeRow(activity: activity) {
                            interactor.restoreChallenge(activity)
                    }
                }
            }
        }
    }
}

