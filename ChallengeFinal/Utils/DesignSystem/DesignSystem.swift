//
//  DesignSystem.swift
//  ChallengeFinal
//
//  Created by Raquel Souza on 16/10/26.
//

import SwiftUI

@Observable
final class DesignSystem {
    static let shared = DesignSystem()
    
    var currentTheme: Theme
    
    private init(currentTheme: Theme = .sober) {
        self.currentTheme = currentTheme
    }
    
    var style: ThemeStyleProtocol { currentTheme.style }
}

extension Theme {
    var style: ThemeStyleProtocol {
        switch self {
        case .sober: return SoberStyle()
        case .bubblegum, .pop, .techNature: return SoberStyle()
        }
    }
}
