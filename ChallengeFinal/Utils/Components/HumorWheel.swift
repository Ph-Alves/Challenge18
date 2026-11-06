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
    
    /// Closure de proximo humor
    let onNext: () -> Void
    
    /// Closure de humor anterior
    let onPrevious: () -> Void
    
    /// Diâmetro externo da roleta.
    private let diameter: CGFloat = 640

    /// Espessura da faixa das fatias.
    private let thickness: CGFloat = 120

    /// Rotação da roleta onde ela parou (sempre múltiplo de `segmentAngle`), em graus.
    /// Acumulada, sem módulo: não volta a 0 depois de uma volta completa.
    @State private var rotation: Double = 0

    /// Rotação extra enquanto o dedo está na tela, em graus. Zera ao soltar.
    @State private var dragRotation: Double = 0

    @State private var isDragging: Bool = false

    /// Última fatia (sem módulo, mesma escala de `rotation`) que já avisamos ao Interactor.
    /// Serve para saber quantas fronteiras foram cruzadas desde o último evento do arraste.
    @State private var lastIndex: Int = 0

    private let humors = Humor.allCases

    /// Quantos graus cada fatia ocupa (5 humores = 72°).
    private var segmentAngle: Double { 360 / Double(humors.count) }

    /// Raio da linha central da faixa: é a distância do dedo ao centro da roleta.
    private var radius: CGFloat { (diameter - thickness) / 2 }

    /// Espaço branco entre as fatias, em graus.
    private let gapAngle: Double = 0

    // MARK: - View

    var body: some View {
        ZStack {
            ForEach(Array(humors.enumerated()), id: \.element) { index, humor in
                segment
                    .stroke(color(for: humor), style: StrokeStyle(lineWidth: thickness, lineCap: .butt))
                    // Gira cada fatia até a posição dela; a fatia 0 fica centralizada no topo.
                    .rotationEffect(.degrees(-90 - segmentAngle / 2 + Double(index) * segmentAngle))
            }
        }
        // O stroke fica metade para fora do círculo: descontamos a espessura.
        .frame(width: diameter - thickness, height: diameter - thickness)
        .rotationEffect(.degrees(rotation + dragRotation))
        .frame(width: diameter, height: diameter)
        // O marcador fica FORA da rotação: ele é fixo, a roleta é que gira.
        .overlay(alignment: .top) {
            pointer
        }
        // O gesto fica fora da rotação: a área de toque é o disco fixo, não as fatias girando.
        .contentShape(Circle())
        .gesture(spin)
        .onAppear {
            lastIndex = index(of: selected)
            rotation = -Double(lastIndex) * segmentAngle
        }
        // Isso roda somente quando o humor alterar por vias externas ao drag (quando ir e voltar da foto, preview ou recuperar dados.
        .onChange(of: selected) { _, newHumor in
            // Mudança vinda de fora do arraste (ex.: preview). Durante o arraste a roleta
            // já está na fatia certa, então não há o que girar.
            guard !isDragging else { return }

            // Caminho mais curto até o novo humor, a partir de onde a roleta está.
            var steps = index(of: newHumor) - mod(lastIndex)
            if steps > humors.count / 2 { steps -= humors.count }
            if steps < -humors.count / 2 { steps += humors.count }
            guard steps != 0 else { return }

            lastIndex += steps
            withAnimation(.spring(duration: 0.4)) {
                rotation -= Double(steps) * segmentAngle
            }
        }
    }

    // MARK: - Gesto

    /// Gira a roleta junto com o dedo; a cada fatia nova que passa pelo marcador
    /// avisa o Interactor, e ao soltar encaixa na fatia mais próxima.
    private var spin: some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { value in
                isDragging = true

                // Comprimento do arco = raio × ângulo (em radianos), então ângulo = arco / raio.
                // O dedo anda ~ na horizontal perto do topo, então usamos o deslocamento em x como arco.
                // `Angle` converte radianos em graus (o que o `rotationEffect` espera).
                dragRotation = Angle(radians: value.translation.width / radius).degrees

                // Fatia sob o marcador: em repouso rotation = -índice × 72°, logo índice = -rotação / 72°.
                // O arredondamento troca de fatia na metade do caminho entre duas fatias.
                let total = rotation + dragRotation
                let currentIndex = Int((-total / segmentAngle).rounded())

                // Quantas fronteiras foram cruzadas desde o último evento (pode ser mais de uma
                // se o dedo for rápido). Positivo = girou para a esquerda = próximo humor.
                let crossed = currentIndex - lastIndex
                if crossed > 0 {
                    for _ in 0..<crossed { onNext() }
                } else if crossed < 0 {
                    for _ in 0..<(-crossed) { onPrevious() }
                }
                lastIndex = currentIndex
            }
            .onEnded { _ in
                // Fixa o que o dedo girou (visualmente igual, então sem animação)...
                rotation += dragRotation
                dragRotation = 0
                isDragging = false

                // ...e encaixa na fatia mais próxima.
                withAnimation(.spring(duration: 0.4)) {
                    rotation = (rotation / segmentAngle).rounded() * segmentAngle
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

    /// Cor de cada fatia: a cor do humor no tema ativo (não muda com a seleção).
    private func color(for humor: Humor) -> Color {
        let colors = DesignSystem.shared.style.colors

        switch humor {
        case .veryUnpleasant: return colors.emotionPessimo
        case .unpleasant: return colors.emotionDesagradavel
        case .neutral: return colors.emotionNeutro
        case .pleasant: return colors.emotionAgradavel
        case .veryPleasant: return colors.emotionOtimo
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

    /// Índice acumulado (pode ser negativo ou passar de 4) → posição em `humors`.
    private func mod(_ index: Int) -> Int {
        ((index % humors.count) + humors.count) % humors.count
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
    @Previewable @State var humor: Humor = .veryUnpleasant
    let humors = Humor.allCases

    HumorWheel(
        selected: humor,
        onNext: {
            let index = humors.firstIndex(of: humor) ?? 0
            humor = humors[(index + 1) % humors.count]
        },
        onPrevious: {
            let index = humors.firstIndex(of: humor) ?? 0
            humor = humors[(index - 1 + humors.count) % humors.count]
        }
    )
}

