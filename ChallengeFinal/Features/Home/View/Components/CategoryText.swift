//
//  CategoryText.swift
//  ChallengeFinal
//
//  Created by Paulo Henrique Costa Alves on 21/10/26.
//

import SwiftUI

struct CategoryText: View {
    
    let category: ActivityCategory
    
    var body: some View {
        HStack {
            Image(systemName: category.icon)
            Text(category.text)
        }
    }
}

#Preview {
    CategoryText(category: .physical)
}
