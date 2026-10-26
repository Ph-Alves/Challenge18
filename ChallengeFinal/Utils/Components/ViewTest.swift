//
//  ViewTest.swift
//  ChallengeFinal
//
//  Created by Débora Cristina Silva Ferreira on 25/10/26.
//

import Foundation
import SwiftUI

struct ViewTest: View {
    var body: some View {
        HStack(spacing: 30) {
            RegisteredActivityCard(title: "tesre", humor: .annoyed)
            RegisteredActivityCard(title: "tesfesfasfhahufhsfhjsahfjahsfhjsajfjasjfjshre", humor: .annoyed)

        }
        .padding(.horizontal, 30)
    }
}


#Preview {
    ViewTest()
}
