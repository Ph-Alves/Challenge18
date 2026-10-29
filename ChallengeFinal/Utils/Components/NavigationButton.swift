//
//  BackButton.swift
//  ChallengeFinal
//
//  Created by Paulo Henrique Costa Alves on 23/10/26.
//

import SwiftUI

struct NavigationButton: View {
    
    let kind: ActivityNavigationButton
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: kind.icon)
        }
        .buttonStyle(.glass)
    }
}

#Preview {
    VStack {
        NavigationButton(kind: .back, action: {})
        NavigationButton(kind: .close, action: {})
    }
}
