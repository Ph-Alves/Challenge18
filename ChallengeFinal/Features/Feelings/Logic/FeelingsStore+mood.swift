//
//  FeelingsStore+mood.swift
//  ChallengeFinal
//
//  Created by Paulo Henrique Costa Alves on 02/11/26.
//

import Foundation

extension FeelingsStore {
    func presentFeelingsLoaded(feelings: [Humor: [Activity]]) {
        self.feelings = feelings
    }
}
