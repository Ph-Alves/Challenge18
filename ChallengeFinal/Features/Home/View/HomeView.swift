//
//  HomeCoordinatorView.swift
//  ChallengeFinal
//
//  Created by Raquel Souza on 19/10/26.
//

import SwiftUI

struct HomeView: View {

    let interactor: HomeInteractorProtocol
    @Bindable var store: HomeStore
    
    var body: some View {
        HStack {
            VStack {
                Text("Hello!")
                Text("sorteie um novo desafio!")
            }
            
            Text("<3")
                .overlay {
                    Circle().strokeBorder(.black, lineWidth: 4)
                }
        }
    }
}

// MARK: - Stub pro preview

private final class HomeInteractorStub: HomeInteractorProtocol {
    func getCategory() -> [Category] { return [] }
}

extension HomeStore {
    static var preview: HomeStore {
        let state = HomeStore()
        return state
    }
}

#Preview {
    HomeView(interactor: HomeInteractorStub(), store: .preview)
}
