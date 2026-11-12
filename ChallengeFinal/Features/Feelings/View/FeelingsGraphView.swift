//
//  FeelingsGraphView.swift
//  ChallengeFinal
//
//  Created by Paulo Henrique Costa Alves on 02/11/26.
//

import SwiftUI

/// Gráfico de barras "Top emoções": uma barra por humor, com altura
/// proporcional à quantidade de Activities daquele humor.
struct FeelingsGraphView: View {
    
    // MARK: - Variables
    
    @Environment(DesignSystem.self) private var designSystem
    
    /// Activities agrupadas por humor, vindas da Store.
    let feelings: [Humor: [(activity: Activity, image: Image?)]]
    
    /// Pede os dados ao Interactor. Chamada quando a tela aparece.
    let loadAction: () -> Void
    
    /// Altura máxima de uma barra (quando um humor tem 100% das Activities).
    private let barHeight: CGFloat = 330
    
    // MARK: - Body
    
    var body: some View {
        VStack(alignment: .leading, spacing: 40) {
            VStack(spacing: 16) {
                Text("Top emoções")
                    .font(designSystem.currentTheme.style.typography.subtitle1)
                    .padding(.top, 24)
                    .contentTransition(.opacity)
                    
                // Total de Activities com humor, usado como 100% das barras.
                let totalCount = feelings.values.reduce(0) { $0 + $1.count }
                    
                HStack(alignment: .top, spacing: 16) {
                    ForEach(Humor.allCases, id: \.self) { emotion in
                        let count = feelings[emotion]?.count ?? 0
                        // `max(totalCount, 1)` evita dividir por zero quando não há dados.
                        let fraction = Double(count) / Double(max(totalCount, 1))
                        
                        VStack(spacing: 9) {
                            
                            // Ícone do humor abaixo da barra.
                            Image(emotion.icon)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 54, height: 54)
                            
                            // A barra: o preenchimento cresce de baixo para cima
                            // dentro do contorno, que tem sempre a altura total.
                            ZStack(alignment: .bottom) {
                                let height = barHeight * fraction
                                Capsule()
                                    .fill(.gray)
                                    .frame(height: height)
                                
                                Capsule()
                                    .stroke(designSystem.currentTheme.style.colors.backgroundInverse, lineWidth: 2)
                            }
                            .frame(width: 48, height: barHeight)
                            
                            //Nome do humor
                            Text(emotion.rawValue.lowercased())
                                .font(designSystem.currentTheme.style.typography.text3)
                                .lineLimit(1)
                                .minimumScaleFactor(0.7)
                            
                            // Quantidade com dois dígitos, ex.: "(03)".
                            Text("(\(String(format: "%02d", count)))")
                                .font(designSystem.currentTheme.style.typography.text3)
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
                .padding(.horizontal, 20)
                
                Spacer()
            }
            .frame(maxWidth: .infinity)
//            .frame(minHeight: 560)
            .background(RoundedRectangle(cornerRadius: 28).fill(.background))
            .overlay(RoundedRectangle(cornerRadius: 28).stroke(designSystem.currentTheme.style.colors.backgroundInverse, lineWidth: 2))
        }
        // Recarrega toda vez que a tela aparece, para refletir novas Activities.
        .onAppear {
            loadAction()
        }
    }
}

#Preview {
    FeelingsGraphView(feelings: [:], loadAction: {})
        .environment(DesignSystem.shared)
}
