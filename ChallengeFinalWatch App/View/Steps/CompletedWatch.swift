//
//  CompletedWatch.swift
//  ChallengeFinalWatch Watch App
//
//  Created by Paulo Henrique Costa Alves on 19/11/26.
//

import SwiftUI

/// Step `.completed`: o "arrasou" com o botão de voltar para a home.
struct CompletedWatch: View {

    let onHome: () -> Void
    let onClose: () -> Void

    var body: some View {
        VStack(spacing: 21) {
            Text("mais um desafio concluído!")
                .font(.headline)
                .multilineTextAlignment(.center)
                .fontWeight(.bold)
                .padding(.top, 24)

            WatchPillButton(title: "home", style: .primary, action: onHome)
                .padding(.horizontal, 13)
        }
        .navigationTitle("arrasou")
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(role: .close, action: onClose)
            }
        }
    }
}

#Preview {
    NavigationStack {
        CompletedWatch(onHome: {}, onClose: {})
    }
}
