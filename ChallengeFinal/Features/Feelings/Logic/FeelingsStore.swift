//
//  FeelingsStore.swift
//  ChallengeFinal
//
//  Created by Paulo Henrique Costa Alves on 02/11/26.
//

import Foundation

protocol FeelingsStoreProtocol: AnyObject {
    func presentFeelingsLoaded(feelings: [Humor: [Activity]])
}

@MainActor
@Observable
final class FeelingsStore: FeelingsStoreProtocol {
    var feelings: [Humor: [Activity]]?
}
