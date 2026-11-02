//
//  FeelingsGraphView.swift
//  ChallengeFinal
//
//  Created by Paulo Henrique Costa Alves on 02/11/26.
//

import SwiftUI

struct FeelingsGraphView: View {
    
    let feelings: [Humor: [Activity]]
    let loadAction: () -> Void
    private let barHeight: CGFloat = 330
    
    var body: some View {
        VStack(alignment: .leading, spacing: 40) {
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
                    
                let totalCount = feelings.values.reduce(0) { $0 + $1.count }
                    
                HStack(alignment: .top, spacing: 16) {
                    ForEach(Humor.allCases, id: \.self) { emotion in
                        let count = feelings[emotion]?.count ?? 0
                        let fraction = Double(count) / Double(max(totalCount, 1))
                        
                        VStack(spacing: 8) {
                            ZStack(alignment: .bottom) {
                                let height = barHeight * fraction
                                Capsule()
                                    .fill(.gray)
                                    .frame(height: height)
                                
                                Capsule()
                                    .stroke(.black, lineWidth: 2)
                            }
                            .frame(width: 48, height: barHeight)
                            
                            Image(emotion.icon)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 54, height: 54)
                            
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
        .padding(.horizontal, 24)
        .padding(.top, 24)
        .onAppear {
            loadAction()
        }
    }
}

#Preview {
    FeelingsGraphView(feelings: [:], loadAction: {})
}
