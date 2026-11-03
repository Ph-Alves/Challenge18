//
//  FeelingsInteractor.swift
//  ChallengeFinal
//
//  Created by Paulo Henrique Costa Alves on 02/11/26.
//

import Foundation

// MARK: - Protocol

/// O que a View enxerga do Interactor: só as AÇÕES que ela pode pedir.
///
/// Com o protocolo, a View não depende da classe concreta. Nos testes e nos
/// `#Preview`, dá para passar um Interactor falso.
protocol FeelingsInteractorProtocol: AnyObject {
    // MARK: Carregamento (implementado em FeelingsInteractor+mood.swift)
    func loadFeelings()
    func selectActivity(activity: Activity)
    func deleteActivity(activity: Activity)
}

// MARK: - Class

/// O "cérebro" da tela de Feelings.
///
/// Busca as Activities no banco, decide quais entram na conta e avisa o
/// Presenter do resultado.
///
/// Organização:
/// - Este arquivo: dependências e init.
/// - `FeelingsInteractor+mood.swift`: carregamento dos sentimentos.
@MainActor
final class FeelingsInteractor: FeelingsInteractorProtocol {
    
    // MARK: - Dependências
    
    /// Para quem o Interactor manda os resultados. Pelo protocolo, para dar spy nos testes.
    let presenter: FeelingsPresenterProtocol
    
    /// Acesso às Activities salvas no banco.
    let activityRepository: GenericRepository<Activity>
    
    // MARK: - Init
    
    init(presenter: FeelingsPresenterProtocol, activityRepository: GenericRepository<Activity>) {
        self.presenter = presenter
        self.activityRepository = activityRepository
    }
}
