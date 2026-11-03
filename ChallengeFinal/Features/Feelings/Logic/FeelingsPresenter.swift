//
//  FeelingsPresenter.swift
//  ChallengeFinal
//
//  Created by Paulo Henrique Costa Alves on 02/11/26.
//

import Foundation

// MARK: - Protocol

/// O que o Interactor enxerga do Presenter.
///
/// Com o protocolo, nos testes do Interactor dá para usar um *spy*
/// (um Presenter falso que só anota o que foi chamado), sem Store nem View.
protocol FeelingsPresenterProtocol: AnyObject {
    // MARK: Carregamento (implementado em FeelingsPresenter+mood.swift)
    func presentFeelingsLoaded(activities: [Activity])
}

// MARK: - Class

/// O "tradutor" da tela de Feelings.
///
/// Recebe as Activities cruas do Interactor, organiza por humor e entrega
/// para a Store.
///
/// Regras:
/// - Não chama Interactor, Worker nem Coordinator.
/// - Não decide regra de negócio (isso é do Interactor), só COMO mostrar.
/// - Só conhece a Store pelo `FeelingsStoreProtocol`.
@MainActor
final class FeelingsPresenter: FeelingsPresenterProtocol {
    
    // MARK: - Variables
    
    /// Não é `private` porque `FeelingsPresenter+mood.swift` também usa.
    weak var store: FeelingsStoreProtocol?
    
    // MARK: - Init
    
    init(store: FeelingsStoreProtocol) {
        self.store = store
    }
}
