//
//  RegisteredActivityCard.swift
//  ChallengeFinal
//
//  Created by Débora Cristina Silva Ferreira on 23/10/26.
//

import Foundation
import SwiftUI

struct RegisteredActivityCard: View {
    @Environment(DesignSystem.self) private var designSystem
    var title: String
    var humor: Humor?
    let photo: Image?
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            VStack(alignment: .leading, spacing: 12) {
                PhotoCard(photo: photo, height: 120, cornerRadius: 16)
                    .padding(.top, 10)
                
                Text(title)
                    .lineLimit(1)
                    .font(designSystem.style.typography.text3)
                    .padding(.leading, 2)
                    .padding(.bottom, 12)
            }
            .padding(.horizontal, 12)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(designSystem.style.colors.backgroundPrimary)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(designSystem.style.colors.strokeDefault, lineWidth: 1.5)
            )
            
            if let humor {
                HumorIconBadge( humor: humor, size: 33).offset(x: 14, y: 12)
            }
        }
    }
}

//MARK: - Previews
#Preview {
    HStack(spacing: 24) {
        RegisteredActivityCard(title: "Com foto", humor: .veryPleasant, photo: Image(systemName: "person.crop.square.fill"))
        RegisteredActivityCard(title: "Sem foto e sem humor", humor: nil, photo: nil)
    }
    .padding(32)
    .environment(DesignSystem.shared)
}

struct HumorIconBadge: View {
    @Environment(DesignSystem.self) private var designSystem
    let humor: Humor
    var size: CGFloat

    var body: some View {
        
        Image(humor.cardIcon)
            .resizable()
            .frame(width: size, height: size)
            .padding(8)
            .background(
                RoundedRectangle(cornerRadius: 6).fill(designSystem.style.colors.fillPrimary)
            )
    }
}
