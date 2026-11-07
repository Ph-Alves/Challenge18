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
    
    //MARK: - DESIGN SYSTEM
    @Environment(DesignSystem.self) private var designSystem
    
    //atalhos
    private var typography: Typography { designSystem.style.typography }
    private var colors: ColorPalette { designSystem.style.colors }
    private var icons: IconsSet { designSystem.style.icons }
    
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
                .padding(.top, 70)
            
            Spacer(minLength: 32)
            
            wheelArea
            
            continueButton.padding(.bottom, 60)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(colors.backgroundPrimary)
    }
    
    // MARK: - Título
    
    private var header: some View {
        VStack(spacing: 16) {
            Text("reflita!")
                .font(typography.title2)
            
            Text("como você se sentiu\ndurante esse desafio?")
                .font(typography.text2)
        }
        .multilineTextAlignment(.center)
        .foregroundStyle(colors.textPrimary)
    }
    
    // MARK: - Roleta
    
    /// Área da roleta: o círculo é maior que a tela, então ele entra como
    /// overlay de um `Color.clear` (que não cresce) e o `.clipped()` corta as sobras.
    private var wheelArea: some View {
        Color.clear
            .frame(height: 340)
            .overlay(alignment: .top) {
                ZStack(alignment: .top) {

                    Image(designSystem.style.humorWheel.backgroundAsset)
                        .resizable()
                        .scaledToFit()
                       .frame(width: 480, height: 221)
                       .padding(.top, -20)
                       .allowsHitTesting(false)

                    HumorWheel(selected: humor, onNext: onNext, onPrevious: onPrevious)
                        .padding(.top, 40) // espaço para o marcador (o offset dele)
                }
            }
            .overlay(alignment: .top) {
                humorInfo
                    .padding(.top, 187) // logo abaixo da faixa da roleta
                    .allowsHitTesting(false) // o arraste passa para a roleta
            }
    }
    /// Emoji, nome e descrição do humor selecionado.
    private var humorInfo: some View {
        VStack(spacing: 12) {
            Image(humor.icon)
                .resizable()
                .scaledToFit()
                .frame(width: 64, height: 64)
            
            Text(humor.rawValue.lowercased())
                .font(typography.subtitle2.bold())
                .foregroundStyle(colors.textPrimary)
        }
        .multilineTextAlignment(.center)
        .foregroundStyle(.pink)
        // Troca suave quando o humor muda.
        .id(humor)
        .transition(.opacity)
        .animation(.easeInOut(duration: 0.2), value: humor)
    }
    
    // MARK: - Botões
    
    private var continueButton: some View {
        CustomButtonComponent(
            title: style == .activity ? "continuar" : "salvar",
            icon: nil,
            type: .secondary,
            action: onContinue
        )
        .frame(width: 140)
    }
}

// MARK: - Preview

#Preview("Em uma sheet") {
    @Previewable @State var humor: Humor = .pleasant
    @Previewable @State var isPresented = true
 
//    Button("abrir reflexão") { isPresented = true }
//        .sheet(isPresented: $isPresented) {
            MoodStepView(
                style: .reflection,
                humor: humor,
                onNext: { humor = humor.moved(by: 1) },
                onPrevious: { humor = humor.moved(by: -1) },
                onContinue: { isPresented = false }
            )
//        }
        .environment(DesignSystem.shared)
}

