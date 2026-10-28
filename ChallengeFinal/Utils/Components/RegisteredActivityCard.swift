//
//  RegisteredActivityCard.swift
//  ChallengeFinal
//
//  Created by Débora Cristina Silva Ferreira on 23/10/26.
//

import Foundation
import SwiftUI

struct RegisteredActivityCard: View {
    var title: String
    var humor: Humor
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            VStack(alignment: .leading, spacing: 11) {
                RoundedRectangle(cornerRadius: 12)
                    .fill(.gray.opacity(0.2))
                    .frame(height: 114)
                    
                
                Text(title)
                    .lineLimit(1)
                    .font(.footnote)
                    .padding(.leading, 8)
                    .padding(.bottom, 8)
            }
            .padding(.top, 11)
            .padding(.bottom, 22)
            .padding(.horizontal, 12)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.white)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(.black, lineWidth: 2)
            )
            
            Image(humor.icon)
                .resizable()
                .frame(width: 44, height: 44)
                
                .offset(x: 8, y: 8)
        }
    }
}

#Preview {
    RegisteredActivityCard(title: "Titulo do desafio", humor: .frustrated)
}
