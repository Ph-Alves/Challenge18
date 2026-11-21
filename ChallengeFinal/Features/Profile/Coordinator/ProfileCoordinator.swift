//
//  ProfileCoordinator.swift
//  ChallengeFinal
//
//  Created by Raquel Souza on 16/11/26.
//

import Foundation
import SwiftData

/// Como o sheet de configurações é apresentado pela própria View (estado na Store),
/// então aqui só montamos a view pelo Builder e guardamos em cache.
@MainActor
final class ProfileCoordinator: ProfileRouting {

    var cached: ProfileView?

    func startProfileView(context: ModelContext) -> ProfileView {
        if let cached {
            return cached
        }

        let view = ProfileBuilder.build(context: context)
        cached = view
        return view
    }
}
