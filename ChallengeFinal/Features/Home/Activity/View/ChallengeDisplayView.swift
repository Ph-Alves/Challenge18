//
//  ChallengeDisplayView.swift
//  ChallengeFinal
//
//  Created by Paulo Henrique Costa Alves on 25/10/26.
//

import SwiftUI

struct ChallengeDisplayView: View {

    let challengeTitle: String
    let archiveAction: () -> Void
    let acceptAction: () -> Void
    let refuseAction: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            ZStack(alignment: .bottom) {
                ChallengeCircle(text: challengeTitle, size: .big)
                    .offset(y: -110)
                VStack(spacing: 19) {
                    Text("Gostaria de iniciar esse desafio?")
                        .bold()
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 72)

                    HStack {
                        Spacer()
                        Button(action: refuseAction, label: {
                            Text("outro desafio")
                        })
                        .buttonStyle(.plain)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 5)
                        .background(.gray.opacity(0.3))
                        .clipShape(RoundedRectangle(cornerRadius: 39))

                        Spacer()
                        Button(action: acceptAction, label: {
                            Text("aceitar")
                                .foregroundStyle(.white)
                        })
                        .buttonStyle(.plain)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 5)
                        .background(.gray)
                        .clipShape(RoundedRectangle(cornerRadius: 39))

                        Spacer()
                    }
                }
                .padding()
                .background(.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay{
                    RoundedRectangle(cornerRadius: 12).stroke(lineWidth: 1)
                }
                .padding(.horizontal)
            }
            Button(action: archiveAction, label: {
                HStack {
                    Image(systemName: "archivebox.fill")
                    Text("Arquivar desafio da lista")
                }
            })
            .buttonStyle(.plain)
            .padding(.horizontal, 20)
            .padding(.vertical, 5)
            .background(.gray.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 39))
        }
    }
}

#Preview {
    ChallengeDisplayView(challengeTitle: "teste", archiveAction: {}, acceptAction: {}, refuseAction: {})
}
