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
        
        var body: some View {
            Button {
                isSelected.toggle()
            } label: {
                HStack {
                    Image(humor.icon)
//                        .renderingMode(.template)
                        .resizable()
                        .frame(width: 27, height: 27)
//                        .foregroundStyle(designSystem.currentTheme.style.colors.textInverse)
                    Text(humor.rawValue)
                        .font(designSystem.currentTheme.style.typography.subtitle1)
                        .foregroundStyle(designSystem.currentTheme.style.colors.textInverse)
                        .bold()
                    
                    Text("(\(count))")
                        .foregroundStyle(designSystem.currentTheme.style.colors.textInverse)
                    
                    Spacer()
                    
                    Image(systemName: isSelected ? "chevron.up" : "chevron.down")
                        .foregroundStyle(designSystem.currentTheme.style.colors.textInverse)
                }
            }
            .contentShape(RoundedRectangle(cornerRadius: 12))
            .buttonStyle(.plain)
            .padding(.horizontal, 24)
            .padding(.vertical, 19)
            .background(designSystem.currentTheme.style.colors.fillPrimary)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            
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
