//
//  CategoryText.swift
//  ChallengeFinal
//
//  Created by Paulo Henrique Costa Alves on 21/10/26.
//

import SwiftUI

struct CategoryText: View {
    
    // MARK: - Variables
    let category: ActivityCategory
    
    // MARK: - View
    var body: some View {
        HStack {
            Image(systemName: category.icon)
            Text(category.text)
        }
    }
}

// MARK: - Preview
#Preview {
    CategoryText(category: .physical)
}
