//
//  ChallengeCircle.swift
//  ChallengeFinal
//
//  Created by Paulo Henrique Costa Alves on 22/10/26.
//

import SwiftUI

struct ChallengeCircle: View {
    // MARK: - Variables
    let text: String

    // MARK: - View
    var body: some View {
        ZStack {
            Circle()
                .stroke(LinearGradient(colors: [.black, .gray], startPoint: UnitPoint(x: 1, y: 1), endPoint: UnitPoint(x: 0, y: 1)), lineWidth: 45)
                .frame(width: 300, height: 300)

            Text(text)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 190)
        }
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: 40) {
        ChallengeCircle(text: "Escolha as escadas: Na próxima oportunidade, use as escadas em vez do elevador, se for seguro e viável.")
        ChallengeCircle(text: "Descubra sua própria mão: Observe sua mão e identifique mentalmente o máximo de características que conseguir: linhas, marcas, formatos, texturas e detalhes.")
        ChallengeCircle(text: "Bata claras à mão: Na próxima receita adequada, bata as claras em neve manualmente com um batedor, sem usar uma batedeira elétrica.")
    }
}
