//
//  OnBoardingFourthPage.swift
//  ChallengeFinal
//
//  Created by Débora Cristina Silva Ferreira on 17/11/26.
//

import Foundation
import SwiftUI

// Mostra cada categoria com o mesmo swipe horizontal da Home.
struct OnBoardingFourthPage: View {

    // MARK: - Variables

    @Environment(DesignSystem.self) private var designSystem
    @Binding var selectedCategory: ActivityCategory?
    @ScaledMetric private var circleSize: CGFloat = 108
    let namespace: Namespace.ID
    @State private var showContent = false
    @State private var userHasSwiped = false
    @State private var handOpacity: Double = 1

    @State private var showHand = true
    @State private var handOffset: CGFloat = -10
    var body: some View {
        VStack {
            Spacer()
            ScrollView(.horizontal) {
                HStack(spacing: 0) {
                    ForEach(ActivityCategory.allCases, id: \.self) { category in
                        VStack {
                            ChallengeCircle(category: category, text: nil, isOpen: false, size: circleSize)
                                .hero(category == .physical, in: namespace)
                            
                            CategoryText(category: category)
                                .font(designSystem.currentTheme.style.typography.title2)
                                .padding(.top, 16)
                                .opacity(showContent ? 1 : 0)

                            Text(category.description)
                                .font(designSystem.currentTheme.style.typography.text1)
                                .multilineTextAlignment(.center)
                                .padding(.top, 38)
                                .opacity(showContent ? 1 : 0)

                        }
                        .padding(.horizontal, 60)
                        .containerRelativeFrame(.horizontal)
                        .id(category)
                    }
                }
                .scrollTargetLayout()
            }
            .scrollTargetBehavior(.paging)
            .scrollPosition(id: $selectedCategory)
            .scrollIndicators(.hidden)
            
            
            HStack(spacing: 10) {
                ForEach(ActivityCategory.allCases, id: \.self) { category in
                    let isSelected = category == selectedCategory
                    Capsule()
                        .frame(width: isSelected ? 5 : 2, height: isSelected ? 20 : 14)
                }
            }
            .frame(height: 20)
            .animation(.easeInOut(duration: 0.2), value: selectedCategory)
            .padding(.top, 100)
            .opacity(showContent ? 1 : 0)
            
            if showHand {
                Image(designSystem.style.icons.handIcon)
                    .offset(x: handOffset)
                    .opacity(showContent ? 1 : 0)
                    .padding(.top, 18)
            }
            
            Spacer()

        }
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
            userHasSwiped = true
            showHand = false
            withAnimation(.easeOut(duration: 0.4)) {
                handOffset = 0
                handOpacity = 0
            }
        }

    }
}

#Preview {
    @Previewable @Namespace var ns
    @Previewable @State var selected: ActivityCategory? = .physical
    OnBoardingFourthPage(selectedCategory: $selected, namespace: ns).environment(DesignSystem.shared)
}
