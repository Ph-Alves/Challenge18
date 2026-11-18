//
//  WeeklyHumor.swift
//  ChallengeFinal
//
//  Created by Paulo Henrique Costa Alves on 21/10/26.
//

import SwiftUI

// Mostra a semana em colunas (letra do dia + ícone). Para cada WeekDay:
// dia futuro -> círculo apagado; com humor -> ícone do humor; hoje sem registro -> círculo preto;
// dia passado sem registro -> placeholderCheckIcon.
struct WeeklyHumor: View {
    @Environment(DesignSystem.self) private var designSystem
    
    // MARK: - Variables
    var week: [WeekDay]
    
    // MARK: - View
    var body: some View {
        HStack(spacing: 16) {
            ForEach(week, id: \.self) { day in
                VStack {
                    Text(day.label)
                    if day.isFuture {
                        // Ainda não chegou: círculo cinza apagado
                        Circle().stroke(designSystem.style.colors.strokeMuted, lineWidth: 2)
                            .frame(width: 34, height: 34)
                    } else if let humor = day.humor {
                        Image(humor.icon)
                            .resizable()
                            .frame(width: 34, height: 34)
                    } else if day.isToday {
                        // Hoje ainda sem humor: círculo preto
                        Circle().stroke(designSystem.style.colors.textPrimary, lineWidth: 2)
                            .frame(width: 34, height: 34)
                    } else {
                        // Dia passado sem humor registrado
                        Image(designSystem.style.icons.placeholderCheckIcon)
                            .resizable()
                            .frame(width: 34, height: 34)
                    }
                }
            }
        }
    }
}

// MARK: - Preview
#Preview {
    let week = [
        WeekDay(label: "D", humor: .veryPleasant),
        WeekDay(label: "S", humor: .neutral),
        WeekDay(label: "T", humor: nil, isToday: true),
        WeekDay(label: "Q", humor: nil, isFuture: true),
        WeekDay(label: "Q", humor: nil, isFuture: true),
        WeekDay(label: "S", humor: nil, isFuture: true),
        WeekDay(label: "S", humor: nil, isFuture: true)
    ]
    WeeklyHumor(week: week)
        .environment(DesignSystem.shared)
}
