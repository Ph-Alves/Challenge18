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
            SummaryView(
                style: .display,
                title: activity.name,
                description: activity.activityDescription,
                photo: store.selectedPhoto,
                humor: activity.result?.humor,
                onFinish: { interactor.retakePhoto() },
                onShare: { interactor.shareStory() }
            )
            .presentationDragIndicator(.visible)
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
}
