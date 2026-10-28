//
//  HumorWheel.swift
//  ChallengeFinal
//
//  Created by Raquel Souza on 28/10/26.
//

import SwiftUI

/// Roleta de humor do step `.mood`.
///
/// Um círculo dividido em fatias (uma por `Humor`), maior que a tela: só a
/// parte de cima aparece. O humor selecionado fica no topo, embaixo do
/// marcador, pintado de preto. Quando a seleção muda, a roleta gira até ele.
///
/// Só desenha: quem decide a seleção é o Interactor (via Store).
struct HumorWheel: View {

    // MARK: - Variables

    /// Humor no topo da roleta.
    let selected: Humor

    /// Diâmetro externo da roleta.
    var diameter: CGFloat = 640

    /// Espessura da faixa das fatias.
    var thickness: CGFloat = 120

    /// Rotação acumulada da roleta, em graus.
    @State private var rotation: Double = 0

    private let humors = Humor.allCases

    /// Quantos graus cada fatia ocupa (5 humores = 72°).
    private var segmentAngle: Double { 360 / Double(humors.count) }

    /// Espaço branco entre as fatias, em graus.
    private let gapAngle: Double = 0

    // MARK: - View

    var body: some View {
        ZStack {
            ForEach(Array(humors.enumerated()), id: \.element) { index, _ in
                segment
                    .stroke(color(for: index), style: StrokeStyle(lineWidth: thickness, lineCap: .butt))
                    // Gira cada fatia até a posição dela; a fatia 0 fica centralizada no topo.
                    .rotationEffect(.degrees(-90 - segmentAngle / 2 + Double(index) * segmentAngle))
            }
        }
        // O stroke fica metade para fora do círculo: descontamos a espessura.
        .frame(width: diameter - thickness, height: diameter - thickness)
        .rotationEffect(.degrees(rotation))
        .frame(width: diameter, height: diameter)
        // O marcador fica FORA da rotação: ele é fixo, a roleta é que gira.
        .overlay(alignment: .top) {
            pointer
        }
        .animation(.easeInOut(duration: 0.3), value: selected)
        .onAppear {
            rotation = -Double(index(of: selected)) * segmentAngle
        }
        .onChange(of: selected) { oldHumor, newHumor in
            var steps = index(of: newHumor) - index(of: oldHumor)

            // Caminho mais curto: do último para o primeiro é 1 passo, não 4.
            if steps > humors.count / 2 { steps -= humors.count }
            if steps < -humors.count / 2 { steps += humors.count }

            withAnimation(.spring(duration: 0.4)) {
                rotation -= Double(steps) * segmentAngle
            }
        }
    }

    // MARK: - Fatia

    /// Um pedaço do círculo com o tamanho de uma fatia.
    private var segment: some Shape {
        let fraction = 1 / Double(humors.count)
        let gap = gapAngle / 360
        return Circle().trim(from: gap / 2, to: fraction - gap / 2)
    }

    /// Cor de cada fatia conforme a posição em relação ao humor selecionado.
    private func color(for index: Int) -> Color {
        let count = humors.count
        let offset = (index - self.index(of: selected) + count) % count

        switch offset {
        case 0:
            return .black
        case 1:
            return Color._404040
        case count - 1:
            return Color.E_0_E_0_E_0
        default:
            return Color.F_4_F_4_F_4
        }
    }

    // MARK: - Marcador

    /// Triângulo fixo no topo, apontando para o humor selecionado.
    private var pointer: some View {
        Triangle()
            .fill(Color.E_0_E_0_E_0)
            .frame(width: 48, height: 44)
            .offset(y: -20)
    }

    // MARK: - Auxiliares

    private func index(of humor: Humor) -> Int {
        humors.firstIndex(of: humor) ?? 0
    }
}

// MARK: - Triângulo

/// Triângulo apontando para baixo (o marcador da roleta).
private struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

#Preview {
    HumorWheel(selected: .frustrated)
}

