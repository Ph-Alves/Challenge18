//
//  MoodStepView.swift
//  ChallengeFinal
//
//  Created by Raquel Souza on 28/10/26.
//

import SwiftUI

enum MoodStyle {
    case activity    // dentro do fluxo: "continuar", o X vem da toolbar do ActivityView
    case reflection  // aberto do resumo: "salvar", o X vem de quem chama.
}

struct MoodStepView: View {
    
    // MARK: - Variables
    
    let style: MoodStyle
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
            
            continueButton.padding(.bottom, 60)
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
                HumorWheel(selected: humor, onNext: onNext, onPrevious: onPrevious)
                    .padding(.top, 20) // espaço para o marcador
            }
            .overlay(alignment: .top) {
                humorInfo
                    .padding(.top, 172) // logo abaixo da faixa da roleta
            }
            .clipped()
            .contentShape(Rectangle())
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
    
    // MARK: - Botões
    
    private var continueButton: some View {
        CustomButtonComponent(
            title: style == .activity ? "continuar" : "salvar",
            icon: nil, type: .secondary, action: onContinue
        )
        .frame(width: 140)
    }
}

// MARK: - Preview

#Preview("Fluxo de activity") {
    @Previewable @State var humor: Humor = .veryUnpleasant

    MoodStepView(
        style: .activity,
        humor: humor,
        onNext: { humor = Humor.previewMoved(humor, by: 1) },
        onPrevious: { humor = Humor.previewMoved(humor, by: -1) },
        onContinue: { print("continuar") }
    )
}

#Preview("Reflexão") {
    @Previewable @State var humor: Humor = .neutral

    MoodStepView(
        style: .reflection,
        humor: humor,
        onNext: { humor = Humor.previewMoved(humor, by: 1) },
        onPrevious: { humor = Humor.previewMoved(humor, by: -1) },
        onContinue: { print("salvar") }
    )
}

/// Rotação da roleta só para o preview.
private extension Humor {
    static func previewMoved(_ humor: Humor, by offset: Int) -> Humor {
        let humors = Humor.allCases
        let index = humors.firstIndex(of: humor) ?? 0
        return humors[(index + offset + humors.count) % humors.count]
    }
}

