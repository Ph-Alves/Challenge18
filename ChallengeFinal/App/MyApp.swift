import SwiftUI
import SwiftData

@main struct MyApp: App {
    
    //esse State aqui permite que o coordinator seja criado apenas uma vez e viva enquanto o app viver.
    //se eu criasse sem state, cada recriação poderia gerar um coordinator novo
    @State private var appCoordinator = AppCoordinator()
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false

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
            .modelContainer(for: [Activity.self, ActivityResult.self, Profile.self])
            .environment(DesignSystem.shared)
        }
    }
}
