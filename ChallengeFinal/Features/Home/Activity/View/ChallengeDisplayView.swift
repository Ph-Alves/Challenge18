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
        VStack {
            ZStack {
                ChallengeCircle(text: challengeTitle, size: .medium)
                VStack {
                    Text("Gostaria de iniciar esse desafio?")
                    HStack {
                        Button(action: refuseAction, label: {
                            Text("outro desafio")
                        })
                        Button(action: acceptAction, label: {
                            Text("aceitar")
                        })
                    }
                }
            }
            Button(action: archiveAction, label: {
                HStack {
                    Image(systemName: "archivebox.fill")
                    Text("Arquivar desafio da lista")
                }
            })
        }
    }
}

#Preview {
    ChallengeDisplayView(challengeTitle: "teste", archiveAction: {}, acceptAction: {}, refuseAction: {})
}
