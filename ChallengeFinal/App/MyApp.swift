import SwiftUI
import SwiftData

@main struct MyApp: App {
    
    //esse State aqui permite que o coordinator seja criado apenas uma vez e viva enquanto o app viver.
    //se eu criasse sem state, cada recriação poderia gerar um coordinator novo
    @State private var appCoordinator = AppCoordinator()
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false

    // O container é criado aqui (e não só no .modelContainer) para o receiver do Watch gravar
    // no mesmo banco que as telas usam, sem depender de nenhuma view estar na tela.
    private let container: ModelContainer
    // Guardado em propriedade porque o WCSession só mantém o delegate de forma fraca.
    private let phoneConnectivity: PhoneConnectivityWorkerProtocol

    init() {
        do {
            container = try ModelContainer(for: Activity.self, ActivityResult.self, Profile.self)
        } catch {
            fatalError("Não foi possível criar o banco: \(error)")
        }

        // Ativar logo na abertura é o que faz o sistema entregar as atividades que o Watch deixou na fila.
        let worker = PhoneConnectivityWorker(importer: WatchActivityImporter(context: container.mainContext))
        worker.activate()
        phoneConnectivity = worker
    }

    var body: some Scene {
        WindowGroup {
            Group {
                if hasSeenOnboarding {
                    RootView(coordinator: appCoordinator)
                } else {
                    OnboardingView {
                        hasSeenOnboarding = true
                    }
                }
            }
            .modelContainer(container)
            .environment(DesignSystem.shared)
        }
    }
}
