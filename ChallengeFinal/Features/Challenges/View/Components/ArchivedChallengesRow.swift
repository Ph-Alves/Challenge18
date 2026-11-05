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

    var body: some View {
        HStack(spacing: 12) {
            HStack(spacing: 12) {
                Image(systemName: activity.category.icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 40, height: 40)
                    .background(Circle().fill(.gray))
                    .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: 4) {
                    Text(activity.name)
                        .font(.subheadline.bold())
                        .lineLimit(1)

                    if !activity.activityDescription.isEmpty {
                        Text(activity.activityDescription)
                            .font(.caption)
                            .lineLimit(2)
                    }
                }
                .foregroundStyle(.black)

                Spacer(minLength: 0)
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 12)
            .frame(minHeight: 62)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(.black, lineWidth: 2)
            )
            .accessibilityElement(children: .combine)

            CircleIconButton(
                icon: "arrow.clockwise",
                size: 54,
                action: onRestore
            )
        }
    }
}
