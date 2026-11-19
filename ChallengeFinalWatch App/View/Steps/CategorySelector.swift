//
//  CategorySelector.swift
//  ChallengeFinalWatch Watch App
//
//  Created by Paulo Henrique Costa Alves on 19/11/26.
//

import SwiftUI

struct CategorySelector: View {
    
    @State private var selected: WatchCategory = .physical
    var startFlow: () -> Void
    
    var body: some View {
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
                .onTapGesture { startFlow() }
            }
        }
        .tabViewStyle(.verticalPage)
        .navigationTitle("desafie-se!")
        .padding(.top, 5)
    }
}

#Preview {
    CategorySelector(startFlow: { print("Apertou!") })
}
