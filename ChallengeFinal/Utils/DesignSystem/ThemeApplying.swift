//
//  ThemeApplying.swift
//  ChallengeFinal
//
//  Created by Raquel Souza on 19/11/26.
//

import Foundation

/// O que um Interactor precisa do Design System: só trocar o tema do app.
/// Cores, fontes e ícones são assunto da View (via `@Environment`).
///
/// No app quem atende é o `DesignSystem.shared`; nos testes, um spy.
protocol ThemeApplying: AnyObject {
    var currentTheme: Theme { get set }
}

// O DesignSystem já tem `currentTheme`: só declara que atende ao contrato.
extension DesignSystem: ThemeApplying {}
