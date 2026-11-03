//
//  FeelingsBuilder.swift
//  ChallengeFinal
//
//  Created by Paulo Henrique Costa Alves on 02/11/26.
//

import Foundation
import SwiftData

/// Monta a cena VIP de Feelings.
///
/// É o ÚNICO lugar que conhece as classes concretas (`FeelingsStore`,
/// `FeelingsPresenter`, `FeelingsInteractor`). Todo o resto se enxerga por protocolo.
///
/// Ordem de criação (cada um depende do anterior):
/// Store -> Presenter(store) -> Interactor(presenter, repositório) -> View
enum FeelingsBuilder {
    
    @MainActor
    static func build(context: ModelContext) -> FeelingsView {
        let store = FeelingsStore()
        
        let presenter = FeelingsPresenter(store: store)
        
        // Câmera usada para trocar a foto de uma atividade (só liga quando o usuário pede).
        let camera = CameraWorker()
        
        // O repositório lê as Activities salvas no banco (SwiftData) pelo `context`.
        let interactor = FeelingsInteractor(presenter: presenter, activityRepository: GenericRepository(context: context), camera: camera)
        
        // A View segura a Store com força: o Presenter guarda a Store como `weak`.
        // O preview mostra a sessão do mesmo worker que o Interactor usa.
        return FeelingsView(interactor: interactor, store: store, cameraPreview: CameraPreview(session: camera.session))
    }
}
