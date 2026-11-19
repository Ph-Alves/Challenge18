//
//  DrawWatch.swift
//  ChallengeFinalWatch Watch App
//
//  Created by Paulo Henrique Costa Alves on 19/11/26.
//

import SwiftUI

/// Step `.draw`: a bola da categoria e o convite para sacudir o relógio.
struct DrawWatch: View {

    let category: WatchCategory
    /// Por enquanto o toque na bola faz o papel do sorteio (o chacoalhar ainda não existe).
    let onDraw: () -> Void
    let onBack: () -> Void

    var body: some View {
        VStack(spacing: 8) {
            Image(category.imageName)
                .resizable()
                .scaledToFit()
                .onTapGesture(perform: onDraw)

            Text("agite o relógio")
                .font(.headline)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 5)
        .navigationTitle(category.text)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(action: onBack) {
                    Image(systemName: "chevron.left")
                }
                .accessibilityLabel("voltar")
            }
        }
    }
}

#Preview {
    NavigationStack {
        DrawWatch(category: .physical, onDraw: {}, onBack: {})
    }
}
