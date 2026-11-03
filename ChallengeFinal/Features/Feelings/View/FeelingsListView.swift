//
//  FeelingsListView.swift
//  ChallengeFinal
//
//  Created by Paulo Henrique Costa Alves on 03/11/26.
//

import SwiftUI

struct FeelingsListView: View {
    
    /// Activities agrupadas por humor, vindas da Store.
    let feelings: [Humor: [Activity]]
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
        
        var humor: Humor
        var activities: [Activity]?
        var count: Int
        var redirectAction: (Activity) -> Void
        @State private var isSelected: Bool = false
        
        var body: some View {
            Button {
                isSelected.toggle()
            } label: {
                HStack {
                    Image(humor.icon)
                        .resizable()
                        .frame(width: 27, height: 27)
                    Text(humor.rawValue)
                        .font(.system(size: 24))
                        .foregroundStyle(.white)
                        .bold()
                    
                    Text("(\(count))")
                        .foregroundStyle(.white)
                    
                    Spacer()
                    
                    Image(systemName: isSelected ? "chevron.up" : "chevron.down")
                        .foregroundStyle(.white)
                }
            }
            .contentShape(RoundedRectangle(cornerRadius: 12))
            .buttonStyle(.plain)
            .padding(.horizontal, 24)
            .padding(.vertical, 19)
            .background(.black)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            
            if let activities, isSelected {
                ScrollView([.horizontal]) {
                    HStack(spacing: 13) {
                        ForEach(activities, id: \.self) { activity in
                            RegisteredActivityCard(title: activity.name, humor: activity.result?.humor)
                                .frame(width: 150)
                                .onTapGesture {
                                    redirectAction(activity)
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
    FeelingsListView(feelings: [.annoyed: [Activity(category: .cognitive, result: nil, name: "teste", description: "", archived: false)]], redirectAction: {_ in})
}
