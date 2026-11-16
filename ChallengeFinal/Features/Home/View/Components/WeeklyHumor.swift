//
//  WeeklyHumor.swift
//  ChallengeFinal
//
//  Created by Paulo Henrique Costa Alves on 21/10/26.
//

import SwiftUI

// Mostra a semana em colunas (letra do dia + ícone). Para cada WeekDay:
// hoje -> placeholderCheckIcon; com humor -> ícone do humor; senão -> círculo vazio.
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
                    if day.isToday {
                        Image(designSystem.style.icons.placeholderCheckIcon)
                            .resizable()
                            .frame(width: 34, height: 34)
                    } else if let humor = day.humor {
                        Image(humor.icon)
                            .resizable()
                            .frame(width: 34, height: 34)
                    } else {
                        Circle().stroke(designSystem.style.colors.textPrimary, lineWidth: 2)
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
        WeekDay(label: "Q", humor: nil),
        WeekDay(label: "Q", humor: nil),
        WeekDay(label: "S", humor: nil),
        WeekDay(label: "S", humor: nil)
    ]
    WeeklyHumor(week: week)
        .environment(DesignSystem.shared)
}
