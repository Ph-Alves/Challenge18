//
//  WeeklyHumor.swift
//  ChallengeFinal
//
//  Created by Paulo Henrique Costa Alves on 21/10/26.
//

import SwiftUI

// Pega um array da semana e mostra os circulos com base
struct WeeklyHumor: View {
    @Environment(DesignSystem.self) private var designSystem
    
    // MARK: - Variables
    var week: [String]
    
    
    // MARK: - View
    var body: some View {
        HStack(spacing: 17) {
            ForEach(week, id: \.self) { day in
                VStack {
                    Text(day)
                    Circle().stroke(designSystem.style.colors.textPrimary, lineWidth: 2)
                        .frame(width: 34, height: 34)
                }
            }
        }
    }
}

// MARK: - Preview
#Preview {
    let week = ["D", "S", "T", "Q", "Q", "S", "S"]
    WeeklyHumor(week: week)
        .environment(DesignSystem.shared)
}
