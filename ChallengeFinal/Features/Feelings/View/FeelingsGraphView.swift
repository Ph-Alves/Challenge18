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
    
    /// Activities agrupadas por humor, vindas da Store.
    let feelings: [Humor: [Activity]]
    
    /// Pede os dados ao Interactor. Chamada quando a tela aparece.
    let loadAction: () -> Void
    
    /// Altura máxima de uma barra (quando um humor tem 100% das Activities).
    private let barHeight: CGFloat = 330
    
    // MARK: - Body
    
    var body: some View {
        VStack(alignment: .leading, spacing: 40) {
            // Cabeçalho
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
                    
                // Total de Activities com humor, usado como 100% das barras.
                let totalCount = feelings.values.reduce(0) { $0 + $1.count }
                    
                HStack(alignment: .top, spacing: 16) {
                    ForEach(Humor.allCases, id: \.self) { emotion in
                        let count = feelings[emotion]?.count ?? 0
                        // `max(totalCount, 1)` evita dividir por zero quando não há dados.
                        let fraction = Double(count) / Double(max(totalCount, 1))
                        
                        VStack(spacing: 8) {
                            // A barra: o preenchimento cresce de baixo para cima
                            // dentro do contorno, que tem sempre a altura total.
                            ZStack(alignment: .bottom) {
                                let height = barHeight * fraction
                                Capsule()
                                    .fill(.gray)
                                    .frame(height: height)
                                
                                Capsule()
                                    .stroke(.black, lineWidth: 2)
                            }
                            .frame(width: 48, height: barHeight)
                            
                            // Ícone do humor abaixo da barra.
                            Image(emotion.icon)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 54, height: 54)
                            
                            // Quantidade com dois dígitos, ex.: "(03)".
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
            .frame(minHeight: 560)
            .background(RoundedRectangle(cornerRadius: 28).fill(.background))
            .overlay(RoundedRectangle(cornerRadius: 28).stroke(.black, lineWidth: 2))
        }
        .padding(.top, 24)
        // Recarrega toda vez que a tela aparece, para refletir novas Activities.
        .onAppear {
            loadAction()
        }
    }
}

#Preview {
    FeelingsGraphView(feelings: [:], loadAction: {})
}
