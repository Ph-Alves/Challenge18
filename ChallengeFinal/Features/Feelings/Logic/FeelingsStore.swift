//
//  FeelingsStore.swift
//  ChallengeFinal
//
//  Created by Paulo Henrique Costa Alves on 02/11/26.
//

import Foundation

// MARK: - Protocol

/// O que o Presenter enxerga da Store: dados prontos para a tela.
protocol FeelingsStoreProtocol: AnyObject {
    // MARK: Carregamento (implementado em FeelingsStore+mood.swift)
    func presentFeelingsLoaded(feelings: [Humor: [Activity]])
}

// MARK: - Class

/// Estado da tela de Feelings. A View só LÊ daqui; quem escreve é o Presenter.
@MainActor
@Observable
final class FeelingsStore: FeelingsStoreProtocol {
    
    // MARK: - Variables
    
    /// Activities agrupadas por humor. É daqui que o gráfico tira a altura de cada barra.
    /// Não é `private(set)` porque quem escreve é o `FeelingsStore+mood.swift`
    /// (extensions não podem ter propriedades armazenadas, por isso fica aqui).
    var feelings: [Humor: [Activity]] = [:]
}
