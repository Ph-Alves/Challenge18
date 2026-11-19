//
//  HomeWatch.swift
//  ChallengeFinalWatch Watch App
//
//  Created by Paulo Henrique Costa Alves on 19/11/26.
//

import SwiftUI

enum WatchCategory: CaseIterable {
    case physical, cognitive, sensorial, social
    var imageName: String {
        switch self {
        case .physical:
            "eightBall"
        case .cognitive:
            "coffee"
        case .sensorial:
            "cookie"
        case .social:
            "telephone"
        }
    }
    var text: String {
        switch self {
        case .physical:
            "movimento"
        case .cognitive:
            "mente"
        case .sensorial:
            "sentidos"
        case .social:
            "conexão"
        }
    }
}

struct HomeWatch: View {
    @State private var selected: WatchCategory = .physical

    var body: some View {
        NavigationStack {
            TabView(selection: $selected) {
                ForEach(WatchCategory.allCases, id: \.self) { category in
                    VStack(spacing: 8) {
                        Image(category.imageName)   // coffee / eightBall / cookie / telephone
                            .resizable()
                            .scaledToFit()
                        Text(category.text)           // mente / movimento / sentidos / conexão
                            .font(.headline)
                    }
                    .tag(category)
                    .onTapGesture { /* iniciar o desafio de `category` */ }
                }
            }
            .tabViewStyle(.verticalPage)
            .navigationTitle("desafie-se!")
        }
    }
}

#Preview {
    HomeWatch()
}
