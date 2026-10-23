import SwiftUI
import SwiftData

@main struct MyApp: App {
    
    //esse State aqui permite que o coordinator seja criado apenas uma vez e viva enquanto o app viver.
    //se eu criasse sem state, cada recriação poderia gerar um coordinator novo
    @State private var appCoordinator = AppCoordinator()
    
    var body: some Scene {
        WindowGroup {
            RootView(coordinator: appCoordinator)
                .modelContainer(for: [Activity.self, ActivityResult.self, Profile.self])
        }
    }
}
