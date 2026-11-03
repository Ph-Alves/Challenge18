//
//  ChallengesEmptyView.swift
//  ChallengeFinal
//
//  Created by Raquel Souza on 03/11/26.
//

import SwiftUI

// MARK: - Estado vazio
struct ChallengesEmptyView: View {
    let state: ChallengesEmptyState

    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: state.icon)
                .font(.system(size: 34))
                .foregroundStyle(.gray)
                .padding(.bottom, 4)

            Text(state.title)
                .font(.headline)

            Text(state.message)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .multilineTextAlignment(.center)
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 32)
        .padding(.vertical, 48)
        .accessibilityElement(children: .combine)
    }
}
