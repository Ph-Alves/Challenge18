//
//  ProfilePresenter.swift
//  ChallengeFinal
//
//  Created by Raquel Souza on 16/10/26.
//

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


import SwiftUI

protocol ProfilePresenterProtocol: AnyObject {
    //mark: tela profile
    
    //mark: settings sheet
}

@MainActor
final class ProfilePresenter: ProfilePresenterProtocol {
    
}
