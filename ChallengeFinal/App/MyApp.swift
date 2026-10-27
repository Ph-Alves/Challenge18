import SwiftUI
import SwiftData

@main struct MyApp: App {
    
    //esse State aqui permite que o coordinator seja criado apenas uma vez e viva enquanto o app viver.
    //se eu criasse sem state, cada recriação poderia gerar um coordinator novo
    @State private var appCoordinator = AppCoordinator()
    
    var body: some Scene {
        WindowGroup {
            StoryCard(
                challengeName: "faça o seu cárdio sem abrir redes sociais",
                challengeTitle: "menos distração, mais foco",
                challengeDescription: "sem redes sociais, seu cardio vira um momento para cuidar do corpo e desacelerar a mente.",
                challengePhoto: UIImage(named: "test")
            )
//            RootView(coordinator: appCoordinator)
//                .modelContainer(for: [Activity.self, ActivityResult.self, Profile.self])
        }
    }
}
