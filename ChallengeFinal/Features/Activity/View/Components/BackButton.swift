//
//  BackButton.swift
//  ChallengeFinal
//
//  Created by Paulo Henrique Costa Alves on 23/10/26.
//

import SwiftUI

struct BackButton: View {
    
    let action: () -> Void
    
    var body: some View {
        Button(action: action, label: {
            Image(systemName: "chevron.left")
        })
        .buttonStyle(.glass)
    }
}

#Preview {
    BackButton(action: {})
}
