//
//  FeelingsListView.swift
//  ChallengeFinal
//
//  Created by Paulo Henrique Costa Alves on 03/11/26.
//

import SwiftUI

struct FeelingsListView: View {
    
    /// Activities agrupadas por humor, vindas da Store.
    let feelings: [Humor: [(activity: Activity, image: Image?)]]
    let redirectAction: (Activity) -> Void
    
    var body: some View {
        VStack(spacing: 26) {
            ForEach(Humor.allCases, id: \.self) { humor in
                let activities = feelings[humor]
                let count = feelings[humor]?.count
                
                listSection(humor: humor, activities: activities, count: count ?? 0, redirectAction: redirectAction)
            }
        }
    }
    
    private struct listSection: View {
        
        //Variables
        @Environment(DesignSystem.self) private var designSystem
        
        var humor: Humor
        var activities: [(activity: Activity, image: Image?)]?
        var count: Int
        var redirectAction: (Activity) -> Void
        @State private var isSelected: Bool = false
        
        //MARK: - Atalho para usar apenas color.token
        private var colors: ColorPalette { designSystem.currentTheme.style.colors }
        
        var body: some View {
            Button {
                isSelected.toggle()
            } label: {
                HStack {
                    Image(isSelected ? humor.whiteIcon : humor.icon)
                        .resizable()
                        .frame(width: 27, height: 27)
                    
                    Text(humor.rawValue)
                        .font(designSystem.currentTheme.style.typography.subtitle1)
                        .bold()
                    
                    Text("(\(count))")
                    
                    Spacer()
                    
                    Image(systemName: isSelected ? "chevron.up" : "chevron.down")
                }
            }
            .foregroundStyle(isSelected ? colors.textInverse : colors.textPrimary)
            .contentShape(RoundedRectangle(cornerRadius: 12))
            .buttonStyle(.plain)
            .padding(.horizontal, 24)
            .padding(.vertical, 19)
            .background(isSelected ? colors.backgroundInverse: colors.backgroundPrimary)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(colors.backgroundInverse)
            )
            
            if let activities, isSelected {
                ScrollView([.horizontal]) {
                    HStack(spacing: 13) {
                        ForEach(activities, id: \.activity) { entry in
                            RegisteredActivityCard(title: entry.activity.name, humor: entry.activity.result?.humor, photo: entry.image)
                                .frame(width: 150)
                                .onTapGesture {
                                    redirectAction(entry.activity)
                                }
                        }
                    }
                    .padding(1)
                    .padding(.bottom, 19)
                }
            }
        }
    }
}

#Preview {
    FeelingsListView(feelings: [.unpleasant: [(activity: Activity(category: .cognitive, result: nil, name: "teste", description: "", archived: false), image: nil)]], redirectAction: {_ in})
        .environment(DesignSystem.shared)
}
