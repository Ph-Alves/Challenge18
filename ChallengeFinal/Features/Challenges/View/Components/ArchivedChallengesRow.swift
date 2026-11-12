//
//  ArchivedChallengesRow.swift
//  ChallengeFinal
//
//  Created by Raquel Souza on 03/11/26.
//

import SwiftUI

struct ArchivedChallengeRow: View {
    let activity: Activity
    let onRestore: () -> Void
    @Environment(DesignSystem.self) private var designSystem
    @State private var isRestoreAlertPresented = false
    
    var body: some View {
        HStack(spacing: 17) {
            HStack(spacing: 10) {
                Image(activity.category.closedIcon)
                    .resizable()
                    .frame(width: 44, height: 44)
                    .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: 4) {
                    Text(activity.result?.achievementTitle ?? activity.name)
                        .font(designSystem.style.typography.subtitle3)
                        .lineLimit(1)

                    if let date = activity.archivedAt {
                        HStack(spacing: 0) {
                            Text("arquivado em: ")
                                .font(designSystem.style.typography.text3)

                            Text(date.formatted(date: .numeric, time: .omitted))
                                .font(designSystem.style.typography.text3)
                        }
                       
                    }
                }
                Spacer(minLength: 0)
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 11)
            .overlay(
                RoundedRectangle(cornerRadius: 9)
                    .stroke(.black, lineWidth: 2)
            )
            .accessibilityElement(children: .combine)

            CircleIconButton(
                icon: designSystem.style.icons.retryIcon.card,
                size: 20,
                padding: 10,
                action: {
                    isRestoreAlertPresented = true
                },
                background: designSystem.style.colors.fillPrimary
            )
        }
        .alert("Restaurar desafio?", isPresented: $isRestoreAlertPresented) {
            
            Button("Cancelar", role: .cancel) {}
            Button("Restaurar") {
                onRestore()
            }
            
        } message: {
            Text("Deseja restaurar este desafio?")
        }
    }
}

#Preview {
    let activity = Activity(
        category: .physical,
        result: nil,
        name: "Caminhada livre",
        description: "Faça uma caminhada de 20 minutos em um parque perto de você.",
        archived: true
    )
    activity.archivedAt = Date()

    return ArchivedChallengeRow(activity: activity, onRestore: {})
        .environment(DesignSystem.shared)
        .padding()
}
