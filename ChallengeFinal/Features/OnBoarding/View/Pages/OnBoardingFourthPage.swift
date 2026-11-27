//
//  OnBoardingFourthPage.swift
//  ChallengeFinal
//
//  Created by Débora Cristina Silva Ferreira on 17/11/26.
//

import Foundation
import SwiftUI

// Mostra cada categoria com swipe horizontal em qualquer lugar da página.
struct OnBoardingFourthPage: View {
    
    // MARK: - Variables
    
    @Environment(DesignSystem.self) private var designSystem
    @Binding var selectedCategory: ActivityCategory?
    @ScaledMetric private var circleSize: CGFloat = 108
    let namespace: Namespace.ID
    
    @State private var showContent = false
    @State private var userHasSwiped = false
    @State private var goingForward = true
    @State private var handOffset: CGFloat = -10
    
    private var category: ActivityCategory { selectedCategory ?? .physical }
    
    // MARK: - View
    
    var body: some View {
        VStack {
            VStack {
                ChallengeCircle(category: category, text: nil, isOpen: false, size: circleSize)
                    .hero(category, in: namespace)

                CategoryText(category: category)
                    .font(designSystem.currentTheme.style.typography.title2)
                    .padding(.top, 16)
                    .opacity(showContent ? 1 : 0)

                
                Text(category.description)
                    .font(designSystem.currentTheme.style.typography.text1)
                    .multilineTextAlignment(.center)
                    .padding(.top, 30)
                    .opacity(showContent ? 1 : 0)

            }
            .padding(.horizontal, 60)
            .id(category)
            .transition(.push(from: goingForward ? .trailing : .leading))
            
            HStack(spacing: 10) {
                ForEach(ActivityCategory.allCases, id: \.self) { item in
                    let isSelected = item == category
                    Capsule()
                        .frame(width: isSelected ? 5 : 2, height: isSelected ? 20 : 14)
                }
            }
            .frame(height: 20)
            .animation(.easeInOut(duration: 0.2), value: selectedCategory)
            .padding(.top, 100)
            .opacity(showContent ? 1 : 0)

            
            // indicador do swipe com a maozinha
            if !userHasSwiped {
                Image(designSystem.style.icons.handIcon)
                    .offset(x: handOffset)
                    .opacity(showContent ? 1 : 0)
                    .padding(.top, 18)
                    .transition(.opacity)

            }
        }
        // Área do gesto = só a altura do conteúdo, na largura toda
        .frame(maxWidth: .infinity)
        .contentShape(Rectangle())
        .gesture(
            DragGesture(minimumDistance: 20).onEnded { value in
                guard abs(value.translation.width) > abs(value.translation.height) else { return }
                changeCategory(towardsNext: value.translation.width < 0)
            }
        )
        // Depois do gesto: empurra pro topo sem aumentar a área do gesto
        .frame(maxHeight: .infinity, alignment: .top)
        .animation(.easeIn(duration: 0.4), value: showContent)
        .task {
            try? await Task.sleep(for: .milliseconds(500))
            showContent = true
            
            let swipeDuration = 0.8
            var goingRight = true
            while !userHasSwiped && !Task.isCancelled {
                withAnimation(.easeInOut(duration: swipeDuration)) {
                    handOffset = goingRight ? 30 : -10
                }
                goingRight.toggle()
                try? await Task.sleep(for: .seconds(swipeDuration))
            }
        }
        .onChange(of: selectedCategory) {
            withAnimation(.easeOut(duration: 0.4)) { userHasSwiped = true }
        }
    }
    
    // MARK: - Actions
    // Troca a categoria; a direção é definida antes de animar
    // para a view que sai usar a transição do lado certo.
    private func changeCategory(towardsNext: Bool) {
        let all = ActivityCategory.allCases
        guard let index = all.firstIndex(of: category) else { return }
        
        let next = towardsNext ? index + 1 : index - 1
        guard all.indices.contains(next) else { return }
        
        goingForward = next > index
        Task { @MainActor in
            withAnimation(.easeInOut(duration: 0.35)) { selectedCategory = all[next] }
        }
    }
}

#Preview {
    @Previewable @Namespace var ns
    @Previewable @State var selected: ActivityCategory? = .physical
    OnBoardingFourthPage(selectedCategory: $selected, namespace: ns).environment(DesignSystem.shared)
}
