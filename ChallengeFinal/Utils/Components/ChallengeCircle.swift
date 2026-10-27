//
//  ChallengeCircle.swift
//  ChallengeFinal
//
//  Created by Paulo Henrique Costa Alves on 22/10/26.
//

import SwiftUI

enum CircleSize {
    case big
    case medium
    case small
}

struct ChallengeCircle: View {
    // MARK: - Variables
    let text: String
    let size: CircleSize
    var frameSize: CGFloat {
        switch size {
        case .big:
            return 300
        case .medium:
            return 250
        case .small:
            return 177
        }
    }

    // MARK: - View
    var body: some View {
        ZStack {
            Circle()
                .stroke(LinearGradient(colors: [.black, .gray], startPoint: UnitPoint(x: 1, y: 1), endPoint: UnitPoint(x: 0, y: 1)), lineWidth: 35)
                .frame(width: frameSize, height: frameSize)

            Text(text)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 190)
        }
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: 40) {
        ChallengeCircle(text: "Escolha as escadas: Na próxima oportunidade, use as escadas em vez do elevador, se for seguro e viável.", size: .big)
        ChallengeCircle(text: "Descubra sua própria mão.", size: .medium)
        ChallengeCircle(text: "abc", size: .small)
    }
}
