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

// MARK: - Preview
import SwiftData

@MainActor
private func makeArchivedPreview(seeded: Bool) -> some View {
    // Container em memória: nada vai para o banco de verdade.
    let container = try! ModelContainer(
        for: Activity.self, ActivityResult.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    let context = container.mainContext

    let store = ChallengesStore()
    let presenter = ChallengesPresenter(store: store)
    let interactor = ChallengesInteractor(
        repository: GenericRepository<Activity>(context: context),
        presenter: presenter
    )

    if seeded {
        let samples: [(ActivityCategory, String, String)] = [
            (.social,    "ligar para a família", "um desafio que ficou arquivado."),
            (.physical,  "caminhar 10 minutos",  "dê uma volta no quarteirão sem o celular."),
            (.cognitive, "ler um capítulo",      "escolha um livro e leia um capítulo inteiro."),
            (.sensorial, "ouvir os sons",        "feche os olhos e conte 5 sons ao seu redor.")
        ]
        let activities = samples.map { category, name, description in
            Activity(
                category: category,
                result: nil,
                createdAt: .now,
                name: name,
                description: description,
                archived: true
            )
        }
        store.displayArchivedChallenges(activities, emptyState: nil)
    } else {
        store.displayArchivedChallenges([], emptyState: .noArchived)
    }

    return ArchivedChallengesView(interactor: interactor, store: store)
        .environment(DesignSystem.shared)
        .modelContainer(container)
}

#Preview("com arquivados") {
    makeArchivedPreview(seeded: true)
}

#Preview("vazio") {
    makeArchivedPreview(seeded: false)
}

