//
//  FeelingsSummaryView.swift
//  ChallengeFinal
//
//  Tela de resumo: card central arrastável entre "top emoções" e "top grupos".
//

import SwiftUI

struct FeelingsSummaryView: View {
    private enum Page: Int {
        case emotions, groups

        var title: String {
            switch self {
            case .emotions: "top emoções"
            case .groups: "top grupos"
            }
        }
    }

    @State private var page: Page = .emotions
    @State private var path: [FeelingsDestination] = []

    private let emotions = FeelingsMock.emotions
    private let groups = FeelingsMock.groups

    var body: some View {
        NavigationStack(path: $path) {
            VStack(alignment: .leading, spacing: 40) {
                header
                card
                Spacer(minLength: 0)
            }
            .padding(.horizontal, 24)
            .padding(.top, 24)
            .navigationDestination(for: FeelingsDestination.self) { destination in
                FeelingsDetailView(destination: destination)
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("seus sentimentos")
                .font(.largeTitle.bold())
            Text("acompanhe como tem se sentido")
                .font(.title3)
        }
    }

    private var card: some View {
        VStack(spacing: 16) {
            Text(page.title)
                .font(.title2.bold())
                .padding(.top, 24)
                .contentTransition(.opacity)

            // Paginação arrastável entre as duas visualizações.
            TabView(selection: $page) {
                emotionsChart.tag(Page.emotions)
                groupsChart.tag(Page.groups)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))

            pageIndicator
                .padding(.bottom, 20)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 560)
        .background(RoundedRectangle(cornerRadius: 28).fill(.background))
        .overlay(RoundedRectangle(cornerRadius: 28).stroke(.black, lineWidth: 2))
        .animation(.snappy, value: page)
    }

    private var pageIndicator: some View {
        HStack(spacing: 12) {
            ForEach([Page.emotions, .groups], id: \.rawValue) { item in
                Capsule()
                    .fill(.black)
                    .frame(width: item == page ? 5 : 3, height: item == page ? 32 : 20)
            }
        }
    }

    // MARK: - Gráficos

    private var emotionsChart: some View {
        let maxCount = Double(emotions.map(\.count).max() ?? 1)
        return HStack(alignment: .top, spacing: 16) {
            ForEach(Array(emotions.enumerated()), id: \.element.id) { index, emotion in
                Button {
                    path.append(.emotion(emotion))
                } label: {
                    ChartColumn(
                        fill: Color(white: 0.9 - 0.9 * Double(index) / Double(max(emotions.count - 1, 1))),
                        fraction: Double(emotion.count) / maxCount,
                        icon: .asset(emotion.asset),
                        count: emotion.count
                    )
                }
                .buttonStyle(.plain)
                .accessibilityLabel("\(emotion.name), \(emotion.count)")
            }
        }
        .padding(.horizontal, 20)
    }

    private var groupsChart: some View {
        let maxCount = Double(groups.map(\.count).max() ?? 1)
        return HStack(alignment: .top, spacing: 16) {
            ForEach(groups) { group in
                Button {
                    path.append(.group(group))
                } label: {
                    ChartColumn(
                        segments: group.segments,
                        fraction: Double(group.count) / maxCount,
                        icon: .symbol(group.symbol, background: group.color),
                        count: group.count
                    )
                }
                .buttonStyle(.plain)
                .accessibilityLabel("\(group.name), \(group.count)")
            }
        }
        .padding(.horizontal, 20)
    }
}

/// Barra vertical com contorno, preenchimento proporcional e ícone + contagem embaixo.
private struct ChartColumn: View {
    var fill: Color = .gray
    var segments: [Double] = [1]
    let fraction: Double
    let icon: Icon
    let count: Int

    enum Icon {
        case asset(String)
        case symbol(String, background: Color)
    }

    private let barHeight: CGFloat = 330

    var body: some View {
        VStack(spacing: 8) {
            ZStack(alignment: .bottom) {
                Capsule().fill(.background)
                filled
                Capsule().stroke(.black, lineWidth: 2)
            }
            .frame(width: 48, height: barHeight)

            iconView

            Text("(\(String(format: "%02d", count)))")
                .font(.caption)
        }
        .frame(maxWidth: .infinity)
    }

    @ViewBuilder
    private var iconView: some View {
        switch icon {
        case .asset(let name):
            Image(name)
                .resizable()
                .scaledToFit()
                .frame(width: 54, height: 54)
        case .symbol(let name, let background):
            Image(systemName: name)
                .font(.system(size: 22))
                .foregroundStyle(.white)
                .frame(width: 54, height: 54)
                .background(Circle().fill(background))
        }
    }

    @ViewBuilder
    private var filled: some View {
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
    }
}

#Preview {
    FeelingsSummaryView()
}
