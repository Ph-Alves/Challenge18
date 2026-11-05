//
//  CategoryFilterButton.swift
//  ChallengeFinal
//
//  Created by Raquel Souza on 03/11/26.
//

import SwiftUI

struct CategoryFilterButton: View {
    let category: ActivityCategory
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                // vai quebrar por conta do asset de alta, se quiser testar precisa comentar a imagem ou ajustar o tamanho
                Image(category.closedIcon)

                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(.black)
                    .frame(width: 44, height: 44)
                    .background(
                        Circle().fill(Color.E_0_E_0_E_0)
                    )

                Text(category.text)
                    .font(.caption)
                    .fontWeight(isSelected ? .semibold : .regular)
                    .foregroundStyle(.black)
            }
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("filtrar por \(category.text)")
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}
