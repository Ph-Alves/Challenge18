//
//  FeelingsSummaryView.swift
//  ChallengeFinal
//
//  Tela de resumo: card central arrastável entre "top emoções" e "top grupos".
//

import SwiftUI

struct FeelingsSummaryView: View {
    
    let interactor: FeelingsInteractorProtocol
    @State var store: FeelingsStore

    private let barHeight: CGFloat = 330

    var body: some View {
        VStack(alignment: .leading, spacing: 40) {
            VStack(alignment: .leading, spacing: 2) {
                Text("seus sentimentos")
                    .font(.largeTitle.bold())
                Text("acompanhe como tem se sentido")
                    .font(.title3)
            }
            VStack(spacing: 16) {
                Text("Top emoções")
                    .font(.title2.bold())
                    .padding(.top, 24)
                    .contentTransition(.opacity)
                
                let maxCount = Double(emotions.map(\.count).max() ?? 1)
                HStack(alignment: .top, spacing: 16) {
                    ForEach(Array(emotions.enumerated()), id: \.element.id) { index, emotion in

                        VStack(spacing: 8) {
                            ZStack(alignment: .bottom) {
                                let height = barHeight * fraction
                                if segments.count > 1 {
                                    // Barra empilhada em tons de cinza (visualização de grupos).
                                    VStack(spacing: 0) {
                                        ForEach(Array(segments.enumerated()), id: \.offset) { index, part in
                                            Rectangle()
                                                .fill(Color(white: 0.85 - 0.6 * Double(index) / Double(segments.count - 1)))
                                                .frame(height: height * part)
                                        }
                                    }
                                    .frame(height: height)
                                    .clipShape(Capsule())
                                } else {
                                    Capsule().fill(fill).frame(height: height)
                                }
                                Capsule().stroke(.black, lineWidth: 2)
                            }
                            .frame(width: 48, height: barHeight)

                            Image(icon)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 54, height: 54)

                            Text("(\(String(format: "%02d", count)))")
                                .font(.caption)
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
                .padding(.horizontal, 20)
                
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .frame(height: 560)
            .background(RoundedRectangle(cornerRadius: 28).fill(.background))
            .overlay(RoundedRectangle(cornerRadius: 28).stroke(.black, lineWidth: 2))
        }
        .padding(.horizontal, 24)
        .padding(.top, 24)
    }
}

#Preview {
    FeelingsSummaryView()
}
