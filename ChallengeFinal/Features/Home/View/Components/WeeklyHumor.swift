//
//  WeeklyHumor.swift
//  ChallengeFinal
//
//  Created by Paulo Henrique Costa Alves on 21/10/26.
//

import SwiftUI

struct WeeklyHumor: View {
    
    var week: [String]
    
    var body: some View {
        HStack(spacing: 17) {
            ForEach(week, id: \.self) { day in
                VStack {
                    Text(day)
                    Circle().stroke(.black, lineWidth: 2)
                        .frame(width: 34, height: 34)
                }
            }
        }
    }
}

#Preview {
    let week = ["D", "S", "T", "Q", "Q", "S", "S"]
    WeeklyHumor(week: week)
}
