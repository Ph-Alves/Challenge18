//
//  ProfileRouting.swift
//  ChallengeFinal
//
//  Created by Raquel Souza on 16/11/26.
//

import Foundation
import SwiftData

/// O que quem usa o Coordinator de Perfil enxerga dele.
@MainActor
protocol ProfileRouting {
    /// View já montada, para ser reaproveitada.
    var cached: ProfileView? { get set }

    /// Devolve a view de Perfil (montando pelo Builder se ainda não existir).
    func startProfileView(context: ModelContext) -> ProfileView
}
