//
//  AcceptedWatch.swift
//  ChallengeFinalWatch Watch App
//
//  Created by Paulo Henrique Costa Alves on 19/11/26.
//

import SwiftUI

/// Step `.accepted`: o desafio aceito, com a descrição e o botão de iniciar.
struct AcceptedWatch: View {

    let title: String
    let description: String
    let onStart: () -> Void
    let onClose: () -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: 21) {
                Text(title)
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .padding(.top, 21)
                    .padding(.horizontal, 19)
                    .fontWeight(.bold)

                Rectangle()
                    .fill(Color(white: 0.3))
                    .frame(width: 82, height: 1)

                Text(description)
                    .font(.footnote)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.gray)
                    .padding(.horizontal, 25)
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(role: .close, action: onClose)
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button("iniciar", action: onStart)
                    .padding(6)
            }
        }
    }
}

#Preview {
    NavigationStack {
        AcceptedWatch(
            title: "fazer o cardio sem abrir as redes sociais",
            description: "sem redes sociais, seu cardio vira um momento para cuidar do corpo e desacelerar a mente.",
            onStart: {},
            onClose: {}
        )
    }
}
