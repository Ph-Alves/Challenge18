//
//  ChallengesView.swift
//  ChallengeFinal
//
//  Created by Raquel Souza on 03/11/26.
//

import SwiftUI


struct ChallengesView: View {

    // MARK: - Variables
    let interactor: ChallengesInteractorProtocol
    var store: ChallengesStore
    
    let cameraPreview: CameraPreview

    /// Texto digitado. Fica na View porque o TextField precisa de binding;
    /// a cada mudança, o Interactor recalcula a lista.
    @State private var searchText = ""
    
    /// Controla o alerta "realmente deseja apagar?" do "…" no resumo.
    @State private var isDeleteAlertPresented = false

    private let columns = [
        GridItem(.flexible(), spacing: 28),
        GridItem(.flexible(), spacing: 28)
    ]

    // MARK: - View
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                header
                    .padding(.top, 24)

                ChallengesSearchBar(text: $searchText)
                    .padding(.top, 30)

                filters
                    .padding(.top, 20)

                content
                    .padding(.top, 40)
            }
            .padding(.horizontal, 30)
            .padding(.bottom, 32)
        }
        .scrollDismissesKeyboard(.immediately)
        .background(Color.white)
        .toolbarVisibility(.hidden, for: .navigationBar)
        .onAppear {
            // Recarrega sempre: um desafio pode ter sido concluído em outra aba.
            interactor.loadChallenges()
        }
        .onChange(of: searchText) { _, newValue in
            interactor.search(newValue)
        }
        .sheet(isPresented: isArchivedPresented) {
            ArchivedChallengesView(interactor: interactor, store: store)
                .presentationDragIndicator(.visible)
        }
        .sheet(item: summaryBinding, onDismiss: interactor.summaryDismissed) { activity in
            // Sheet não tem navigation bar própria: o NavigationStack é o que faz a data da SummaryView aparecer lá em cima.
            NavigationStack {
                SummaryView(
                    style: .display,
                    category: activity.category,
                    createdAt: store.selectedCreatedAt,
                    title: activity.name,
                    description: activity.activityDescription,
                    photo: store.selectedPhoto,
                    humor: activity.result?.humor,
                    onFinish: { interactor.retakePhoto() },
                    onShare: { interactor.shareStory() },
                    onReflect: { interactor.openMood() }
                )
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button(role: .close) { interactor.closeSummary() }
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("mais opções", systemImage: "ellipsis") {
                            isDeleteAlertPresented = true
                        }
                    }
                }
                .alert("Realmente deseja apagar?", isPresented: $isDeleteAlertPresented) {
                    Button("Cancelar", role: .cancel) { }
                    Button("Arquivar", role: .destructive) {
                        interactor.deleteChallenge()
                    }
                } message: {
                    Text("Ao apagar os dados, seus registros serão excluídos e o desafio voltará para a lista do grupo.")
                }
            }
            .presentationDragIndicator(.visible)
            // "reflita!": a roleta abre por cima do resumo (que continua aberto por baixo).
            .fullScreenCover(isPresented: isMoodPresented) {
                NavigationStack {
                    MoodStepView(
                        style: .reflection,
                        humor: store.reflectionHumor,
                        onNext: interactor.nextHumor,
                        onPrevious: interactor.previousHumor,
                        onContinue: interactor.saveHumor
                    )
                    .toolbar {
                        ToolbarItem(placement: .topBarLeading) {
                            Button(role: .close, action: interactor.closeMood)
                        }
                    }
                }
            }
            // Com o resumo aberto, o alerta e o share sheet precisam sair DESTE sheet
            // (a tela de baixo não consegue apresentar nada por cima dele).
            .alert("ops", isPresented: isErrorPresented) {
                Button("ok", role: .cancel) { interactor.dismissError() }
            } message: {
                Text(store.errorMessage ?? "")
            }
            .sheet(item: shareBinding) { item in
                ShareSheet(items: item.activityItems) { completed in
                    interactor.didFinishSharing(completed: completed)
                }
                .presentationDetents([.medium, .large])
                .ignoresSafeArea()
            }
        }
        .fullScreenCover(isPresented: isCameraPresented, onDismiss: interactor.cameraDismissed) {
            CameraView(
                preview: cameraPreview,
                flashIcon: store.cameraFlashIcon,
                errorMessage: store.errorMessage,
                closeCamera: interactor.closeCamera,
                toggleFlash: interactor.toggleFlash,
                takePhoto: interactor.takePhoto,
                switchCamera: interactor.switchCamera,
                didSelectFromGallery: interactor.didSelectFromGallery,
                dismissAlerts: interactor.dismissError
            )
        }
        .alert("ops", isPresented: isErrorPresented) {
            Button("ok", role: .cancel) { interactor.dismissError() }
        } message: {
            Text(store.errorMessage ?? "")
        }
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
                        RegisteredActivityCard(
                            title: activity.name,
                            humor: activity.result?.humor,
                            photo: Image(data: activity.result?.photo)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.trailing, 8) 
        }
    }
    
    // MARK: - Bindings
    // O sheet e o alerta são abertos pela Store; fechar avisa o Interactor
    // (inclusive quando o sheet é arrastado para baixo).
    private var isArchivedPresented: Binding<Bool> {
        Binding(
            get: { store.isArchivedPresented },
            set: { if !$0 { interactor.closeArchived() } }
        )
    }

    private var isErrorPresented: Binding<Bool> {
        Binding(
            get: { store.errorMessage != nil },
            set: { if !$0 { interactor.dismissError() } }
        )
    }
    
    private var summaryBinding: Binding<Activity?> {
        Binding(
            get: { store.selectedChallenge },
            set: { if $0 == nil { interactor.closeSummary() } }
        )
    }
    
    private var shareBinding: Binding<ShareItem?> {
        Binding(
            get: { store.shareItem },
            set: { if $0 == nil { interactor.didFinishSharing(completed: false) } }
        )
    }
    
    private var isCameraPresented: Binding<Bool> {
        Binding(
            get: { store.isCameraPresented },
            set: { if !$0 { interactor.closeCamera() } }
        )
    }
    
    /// Lê a Store e, se a tela do humor for fechada por fora, avisa o Interactor.
    private var isMoodPresented: Binding<Bool> {
        Binding(
            get: { store.isMoodPresented },
            set: { if !$0 { interactor.closeMood() } }
        )
    }
}


// MARK: - Preview
import SwiftData

@MainActor
private func makeChallengesPreview(seeded: Bool) -> some View {
    // Container em memória: nada vai para o banco de verdade.
    let container = try! ModelContainer(
        for: Activity.self, ActivityResult.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    let context = container.mainContext

    if seeded {
        let samples: [(ActivityCategory, String, String, Humor?, Bool, Int)] = [
            (.physical,  "caminhar 10 minutos", "dê uma volta no quarteirão sem o celular.", .pleasant,     false, 0),
            (.cognitive, "ler um capítulo",     "escolha um livro e leia um capítulo inteiro.", .veryPleasant, false, 1),
            (.sensorial, "ouvir os sons",       "feche os olhos e conte 5 sons ao seu redor.", nil,          false, 2), // sem humor -> "reflita!"
            (.social,    "mandar uma mensagem", "fale com alguém que você não vê há tempo.", .neutral,       false, 3),
            (.physical,  "alongar",             "faça 5 minutos de alongamento.", .unpleasant,              false, 4),
            (.social,    "ligar para a família","um desafio que ficou arquivado.", nil,                     true,  5)
        ]

        for (category, name, description, humor, archived, daysAgo) in samples {
            let result = ActivityResult(time: 600, humor: humor)
            let activity = Activity(
                category: category,
                result: result,
                createdAt: Calendar.current.date(byAdding: .day, value: -daysAgo, to: .now)!,
                name: name,
                description: description,
                archived: archived
            )
            context.insert(activity)
        }
        try? context.save()
    }

    return ChallengesBuilder.build(context: context)
        .environment(DesignSystem.shared)
        .modelContainer(container)
}

#Preview("com desafios") {
    makeChallengesPreview(seeded: true)
}

#Preview("vazio") {
    makeChallengesPreview(seeded: false)
}
