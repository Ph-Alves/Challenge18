//
//  FeelingsDetailView.swift
//  ChallengeFinal
//
//  Detalhamento de uma emoção (lista) ou de um grupo de desafios (grade).
//

import SwiftUI

struct FeelingsDetailView: View {
    let destination: FeelingsDestination

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 32) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("seus sentimentos")
                        .font(.largeTitle.bold())
                    Text("acompanhe como tem se sentido")
                        .font(.title3)
                }

                switch destination {
                case .emotion(let emotion):
                    emotionHeader(emotion)
                    VStack(spacing: 20) {
                        ForEach(FeelingsMock.challenges(for: emotion)) { challenge in
                            ChallengeRow(challenge: challenge)
                        }
                    }
                case .group(let group):
                    groupHeader(group)
                    LazyVGrid(columns: [GridItem(.flexible(), spacing: 16), GridItem(.flexible())], spacing: 16) {
                        ForEach(FeelingsMock.challenges(for: group)) { challenge in
                            ChallengeTile(challenge: challenge)
                        }
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 24)
        }
        .navigationBarBackButtonHidden()
        .toolbar(.hidden, for: .navigationBar)
    }

    private var closeButton: some View {
        Button {
            dismiss()
        } label: {
            Image(systemName: "xmark")
                .font(.footnote.bold())
                .foregroundStyle(.white)
                .frame(width: 32, height: 32)
                .background(Circle().fill(Color(white: 0.25)))
        }
        .accessibilityLabel("Fechar")
    }

    private func emotionHeader(_ emotion: FeelingEmotion) -> some View {
        HStack(spacing: 14) {
            Image(emotion.asset)
                .resizable()
                .scaledToFit()
                .frame(width: 44, height: 44)
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text(emotion.name).font(.title.bold())
                Text("(\(String(format: "%02d", emotion.count)))").font(.callout)
            }
            .foregroundStyle(.white)
            Spacer()
            closeButton
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 18)
        .background(RoundedRectangle(cornerRadius: 20).fill(.black))
    }

    private func groupHeader(_ group: FeelingGroup) -> some View {
        HStack(alignment: .center, spacing: 16) {
            Image(systemName: group.symbol)
                .font(.system(size: 30))
                .foregroundStyle(.black)
                .frame(width: 80, height: 80)
                .background(Circle().fill(.white))
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text(group.name).font(.title2.bold()).lineLimit(2)
                    Text("(\(String(format: "%02d", group.count)))").font(.callout)
                }
                .foregroundStyle(.white)
                GeometryReader { proxy in
                    HStack(spacing: 0) {
                        ForEach(Array(group.segments.enumerated()), id: \.offset) { index, part in
                            Rectangle()
                                .fill(Color(white: 0.2 + 0.6 * Double(index) / Double(max(group.segments.count - 1, 1))))
                                .frame(width: proxy.size.width * part)
                        }
                    }
                    .clipShape(Capsule())
                }
                .frame(height: 40)
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .background(RoundedRectangle(cornerRadius: 28).fill(.black))
        .overlay(alignment: .topTrailing) {
            closeButton.padding(12)
        }
    }
}

// MARK: - Componentes

private struct ChallengeRow: View {
    let challenge: FeelingChallenge

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(challenge.title).font(.headline)
                Text(challenge.category).font(.subheadline)
                Text(challenge.date).font(.subheadline).foregroundStyle(.secondary)
            }
            Spacer()
            Image(systemName: challenge.categorySymbol)
                .font(.title2)
                .foregroundStyle(.white)
                .frame(width: 64, height: 64)
                .background(Circle().fill(Color(white: 0.2)))
        }
        .padding(.horizontal, 28)
        .padding(.vertical, 24)
        .background(RoundedRectangle(cornerRadius: 20).fill(.background))
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(.black, lineWidth: 2))
    }
}

private struct ChallengeTile: View {
    let challenge: FeelingChallenge

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Espaço reservado para a foto do desafio.
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(white: 0.92))
                .aspectRatio(1.1, contentMode: .fit)
            Text(challenge.title).font(.footnote)
        }
        .padding(16)
        .background(RoundedRectangle(cornerRadius: 20).fill(.background))
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(.black, lineWidth: 2))
        .overlay(alignment: .bottomTrailing) {
            Image(challenge.emotionAsset)
                .resizable()
                .scaledToFit()
                .frame(width: 52, height: 52)
                .offset(x: 10, y: 10)
        }
    }
}

#Preview("Emoção") {
    FeelingsDetailView(destination: .emotion(FeelingsMock.emotions[4]))
}

#Preview("Grupo") {
    FeelingsDetailView(destination: .group(FeelingsMock.groups[0]))
}
