//
//  ActivityView.swift
//  ChallengeFinal
//
//  Created by Raquel Souza on 19/10/26.
//

import SwiftUI
import SwiftData

/// Container do fluxo de Activity: mostra a view do step atual
/// e liga os toques de cada step ao Interactor.
struct ActivityView: View {

    /// Para abrir os Ajustes do iPhone no alerta de permissão.
    @Environment(\.openURL) private var openURL

    // Por que `@State` nas três?
    //
    // O `ActivityBuilder.build` é chamado dentro do `.fullScreenCover` da HomeView,
    // e o SwiftUI pode chamar aquele trecho de novo sempre que a Home redesenha.
    // Cada nova chamada cria Store, Worker, Presenter e Interactor NOVOS.
    //
    // `@State(initialValue:)` só usa o valor da PRIMEIRA vez e ignora os seguintes.
    // Assim, a View fica sempre com o mesmo conjunto (o primeiro), e os três
    // continuam combinando entre si: a `session` mostrada no preview é a do
    // mesmo worker que o Interactor usa.
    @State var interactor: any ActivityInteractorProtocol
    @State var store: ActivityStore
    @State var cameraPreview: CameraPreview
    
    /// Categoria escolhida na Home, usada no sorteio.
    let currentCategory: ActivityCategory

    var body: some View {
        stepView
            .animation(.easeInOut(duration: 0.4), value: store.currentStep)
            .onAppear {
                interactor.prepare(for: currentCategory)
            }
            // Permissão de câmera negada.
            .alert("Câmera bloqueada", isPresented: isPermissionAlertPresented) {
                Button("Abrir Ajustes") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        openURL(url)
                    }
                    interactor.dismissAlerts()
                }
                Button("Agora não", role: .cancel) {
                    interactor.dismissAlerts()
                }
            } message: {
                Text(store.permissionAlertMessage ?? "")
            }
            // Erros (falha na captura, câmera indisponível, galeria...).
            .alert("Ops!", isPresented: isErrorAlertPresented) {
                Button("OK", role: .cancel) {
                    interactor.dismissAlerts()
                }
            } message: {
                Text(store.errorMessage ?? "")
            }
            // Tela da câmera: abre e fecha conforme `store.isCameraPresented`.
            .fullScreenCover(isPresented: isCameraPresented) {
                CameraView(interactor: interactor, store: store, preview: cameraPreview)
            }
    }

    // MARK: - Steps

    @ViewBuilder
    private var stepView: some View {
        switch store.currentStep {
        case .photo:
            PhotoStepView(
                photo: store.photo,
                onTakePhoto: { interactor.openCamera() },
                onGalleryItemSelected: { item in interactor.didSelectFromGallery(item) },
                onContinue: { interactor.continueFromPhoto() }
            )

        // Sorteio: a tela liga o acelerômetro ao aparecer e desliga ao sair.
        // Quando o desafio fica pronto, a bola cresce e `growFinished` avança para `.challenge`.
        // A seta de voltar encerra o fluxo e devolve o usuário à Home.
        case .draw:
            DrawChallengeView(
                isSearching: store.isSearching,
                isChallengeReady: store.isChallengeReady,
                swipeRaffle: { interactor.raffle(for: currentCategory) },
                startDetection: { interactor.detectMotion(for: currentCategory) },
                finishDetection: { interactor.finishDetection() },
                returnAction: { interactor.finishActivityFlow() },
                growFinished: { interactor.goToActivityDetail() }
            )
            .transition(.opacity)

        case .challenge:
            challengeStepView

        // Em andamento: mostra o desafio e o cronômetro (`store.timeText`, atualizado a cada tick).
        // "encerrar" para o cronômetro e segue para o humor; "cancelar" (já confirmado no alerta
        // da própria tela) sai do fluxo, e o `finishActivity` cancela o cronômetro antes.
        case .inProgress:
            InProgressView(message: store.activityTitle ?? "", challengeSubTitle: store.activitySubtitle ?? "", challengeDescription: store.activityDescription ?? "", timeText: store.timeText, finishAction: {interactor.completeActivity()}, cancelAction: interactor.finishActivityFlow)
            
        // Os outros steps continuam como placeholder até serem implementados
        case .mood:       placeholder("Humor") { interactor.selectMood() }
            
        case .summary:
            summaryStepView
        }
    }

    /// Step `.challenge`: desafio sorteado ou, depois de aceito, a tela de desafio aceito.
    @ViewBuilder
    private var challengeStepView: some View {
        if let title = store.activityTitle,
           let subtitle = store.activitySubtitle,
           let description = store.activityDescription {
            // Antes de aceitar: aceitar, pedir outra opção ou arquivar.
            // "Outra opção" e "arquivar" geram outro desafio por baixo dos panos
            // (o arquivar salva antes) e continuam nesta tela.
            if !store.isChallengeAccepted {
                ChallengeDisplayView(
                    challengeTitle: title,
                    isSearching: store.isSearching,
                    returnAction: { interactor.finishActivityFlow() },
                    archiveAction: {
                        interactor.archiveActivity(title: title, description: subtitle, in: currentCategory)
                        interactor.reroll(for: currentCategory)
                    },
                    acceptAction: { interactor.acceptActivity() },
                    refuseAction: { interactor.reroll(for: currentCategory) }
                )
                .transition(.opacity)
            // Depois de aceitar: "iniciar" segue para `.inProgress`; "cancelar" gera outro desafio.
            } else {
                ChallengeAcceptedView(
                    challengeTitle: title,
                    challengeSubTitle: subtitle,
                    challengeDescription: description,
                    returnAction: { interactor.finishActivityFlow() },
                    startAction: { interactor.startActivity() },
                    cancelAction: { interactor.reroll(for: currentCategory) }
                )
            }
        }
    }
    
    /// Step `.summary`: tela "desafio finalizado".
    /// Os dados já estão na Store desde os steps anteriores (desafio, foto, humor).
    /// Ao aparecer, pede ao Interactor para gerar a imagem do story.
    private var summaryStepView: some View {
        SummaryStepView(
            title: store.activitySubtitle ?? "",
            description: store.activityDescription ?? "",
            photo: store.photo,
            humor: store.humor,
            onFinish: { interactor.finishActivityFlow() },
            // A imagem do story já está pronta na Store: só repassamos.
            onShare: { interactor.shareStory(store.storyImage) }
        )
        .transition(.opacity)
        .onAppear {
            interactor.loadSummary(
                title: store.activityTitle,
                subtitle: store.activitySubtitle,
                description: store.activityDescription
            )
        }
    }

    //CHANGE: remover quando todos os steps tiverem as suas views.
    @ViewBuilder
    private func placeholder(_ title: String, next: @escaping () -> Void) -> some View {
        VStack(spacing: 24) {
            Text(title)

            Button("Próximo", action: next)
                .buttonStyle(.borderedProminent)
        }
    }

    // MARK: - Câmera

    /// Mesmo padrão dos alertas: lê a Store e, se a tela for fechada,
    /// avisa o Interactor (que para a sessão da câmera).
    private var isCameraPresented: Binding<Bool> {
        Binding(
            get: { store.isCameraPresented },
            set: { isPresented in
                if !isPresented { interactor.closeCamera() }
            }
        )
    }
    
    // MARK: - Share sheet

    /// lê a Store e, se o usuário fechar o sheet arrastando para baixo, avisa o Interactor (que pede para limpar a Store).
    private var shareItem: Binding<ShareItem?> {
        Binding(
            get: { store.shareItem },
            set: { item in
                if item == nil { interactor.didFinishSharing(completed: false) }
            }
        )
    }

    // MARK: - Alertas
    //
    // O `.alert` precisa de um Binding<Bool>, mas a View só LÊ a Store.
    // Então o "get" lê a Store, e o "set" (quando o usuário fecha o alerta)
    // avisa o Interactor, que pede ao Presenter para limpar a mensagem.

    private var isPermissionAlertPresented: Binding<Bool> {
        Binding(
            get: { store.permissionAlertMessage != nil },
            set: { isPresented in
                if !isPresented { interactor.dismissAlerts() }
            }
        )
    }

    private var isErrorAlertPresented: Binding<Bool> {
        Binding(
            get: { store.errorMessage != nil },
            set: { isPresented in
                if !isPresented { interactor.dismissAlerts() }
            }
        )
    }
}

// MARK: - Preview
#Preview {
    // Usa o Builder com um container em memória, pra montar o mesmo conjunto do app.
    let container = try! ModelContainer(
        for: Activity.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    let coordinator = ActivityCoordinator(selectedCategory: .cognitive, onFinish: {})

    return ActivityBuilder.build(
        coordinator: coordinator,
        context: container.mainContext,
        currentCategory: .cognitive
    )
}
