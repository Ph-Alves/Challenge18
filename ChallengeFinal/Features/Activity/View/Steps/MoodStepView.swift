//
//  MoodStepView.swift
//  ChallengeFinal
//
//  Created by Raquel Souza on 28/10/26.
//

import SwiftUI

struct MoodStepView: View {

    // MARK: - Variables

    /// Humor no topo da roleta.
    let humor: Humor

    /// Swipe para a esquerda.
    let onNext: () -> Void
    /// Swipe para a direita.
    let onPrevious: () -> Void
    /// Toque em "continuar".
    let onContinue: () -> Void

    // MARK: - View

    var body: some View {
        VStack(spacing: 0) {
            header
                .padding(.top, 24)

            Spacer(minLength: 32)

            wheelArea

            continueButton
                .padding(.bottom, 60)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)
    }

    // MARK: - Título

    private var header: some View {
        VStack(spacing: 16) {
            Text("reflita!")
                .font(.system(size: 28, weight: .bold))

            Text("como você se sentiu\ndurante esse desafio?")
                .font(.system(size: 15))
        }
        .multilineTextAlignment(.center)
        .foregroundStyle(.black)
    }

    // MARK: - Roleta

    /// Área da roleta: o círculo é maior que a tela, então ele entra como
    /// overlay de um `Color.clear` (que não cresce) e o `.clipped()` corta as sobras.
    private var wheelArea: some View {
        Color.clear
            .frame(height: 340)
            .overlay(alignment: .top) {
                HumorWheel(selected: humor)
                    .padding(.top, 20) // espaço para o marcador
            }
            .overlay(alignment: .top) {
                humorInfo
                    .padding(.top, 172) // logo abaixo da faixa da roleta
            }
            .clipped()
            .contentShape(Rectangle())
            .gesture(swipe)
    }

    /// Emoji, nome e descrição do humor selecionado.
    private var humorInfo: some View {
        VStack(spacing: 12) {
            Image(humor.icon)
                .resizable()
                .scaledToFit()
                .frame(width: 64, height: 64)

            Text(humor.rawValue.lowercased())
                .font(.system(size: 20, weight: .bold))

            Text(humor.detail)
                .font(.system(size: 15))
                .padding(.top, 12)
        }
        .multilineTextAlignment(.center)
        .foregroundStyle(.black)
        // Troca suave quando o humor muda.
        .id(humor)
        .transition(.opacity)
        .animation(.easeInOut(duration: 0.2), value: humor)
    }

    /// Mesmo gesto da `HomeView` para trocar de categoria.
    private var swipe: some Gesture {
        DragGesture(minimumDistance: 20)
            .onEnded { value in
                // Se width > height, então é horizontal
                let isHorizontalSwipe = abs(value.translation.width) > abs(value.translation.height)
                guard isHorizontalSwipe else { return }

                // Negativo: direita para esquerda (o humor da direita vem para o topo)
                if value.translation.width < 0 {
                    onNext()
                } else {
                    onPrevious()
                }
            }
    }

    // MARK: - Botão

    private var continueButton: some View {
        CustomButtonComponent(
            title: "continuar",
            icon: nil,
            type: .secondary,
            action: onContinue
        )
        .frame(width: 140)
    }
}

// MARK: - Preview

#Preview("Interativo") {
    @Previewable @State var humor: Humor = .frustrated
    let humors = Humor.allCases

    MoodStepView(
        humor: humor,
        onNext: {
            let index = humors.firstIndex(of: humor) ?? 0
            humor = humors[(index + 1) % humors.count]
        },
        onPrevious: {
            let index = humors.firstIndex(of: humor) ?? 0
            humor = humors[(index - 1 + humors.count) % humors.count]
        },
        onContinue: { print("continuar") },
    )
}
