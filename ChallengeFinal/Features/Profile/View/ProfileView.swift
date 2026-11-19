//
//  ProfileView.swift
//  ChallengeFinal
//
//  Created by Raquel Souza on 16/10/26.
//


import SwiftUI

struct ProfileView: View {
    
    @Environment(DesignSystem.self) private var designSystem
    
    let interactor: ProfileInteractorStub
    @State var store: ProfileStore
    
    var body: some View {
        VStack {
            Text(store.name)
            Text(store.streakText)
        }
    }
}


final class ProfileInteractorStub: ProfileInteractorProtocol {
    
}


extension ProfileStore {
    static var preview: ProfileStore {
        let store = ProfileStore()
        store.displayProfile(name: "Raquel", userPhoto: nil)   // dados falsos para ver a tela
        return store
    }
}

#Preview {
    ProfileView(interactor: ProfileInteractorStub(), store: .preview)
        .environment(DesignSystem.shared)
}
