//
//  ChallengeWatch.swift
//  ChallengeFinalWatch Watch App
//
//  Created by Paulo Henrique Costa Alves on 19/11/26.
//

import SwiftUI

/// Step `.challenge`: o desafio sorteado ("topa?") com aceitar ou pedir outro.
struct ChallengeWatch: View {

    let title: String
    let onAccept: () -> Void
    let onReroll: () -> Void
    let onBack: () -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: 10) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .padding(.top, 21)
                    .padding(.bottom, 11)
                    .padding(.horizontal, 19)

                WatchPillButton(title: "aceitar", style: .primary, action: onAccept)
                    .padding(.horizontal, 13)
                WatchPillButton(title: "outro desafio", style: .secondary, action: onReroll)
                    .padding(.horizontal, 13)
            }
        }
        .navigationTitle("topa?")
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
        ChallengeWatch(
            title: "fazer o cardio sem abrir as redes sociais",
            onAccept: {},
            onReroll: {},
            onBack: {}
        )
    }
}
