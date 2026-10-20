import SwiftUI

//é aqui que o coordinator raiz é criado e onde a TabView vai viver.

@main struct MyApp: App {
    
    //esse State aqui permite que o coordinator seja criado apenas uma vez e viva enquanto o app viver.
    //se eu criasse sem state, cada recriação poderia gerar um coordinator novo
    @State private var appCoordinator = AppCoordinator()
    
    var body: some Scene {
        WindowGroup {
            RootView(coordinator: appCoordinator)
            //ContentView() // no lugar do contentView eu vou colocar uma view raiz que lê o estado do Coordinator.
        }
    }
}
