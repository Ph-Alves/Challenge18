//
//  FeelingsPresenter+Feelings.swift
//  ChallengeFinal
//
//  Created by Paulo Henrique Costa Alves on 02/11/26.
//

import Foundation

extension FeelingsPresenter {
    func presentFeelingsLoaded(activities: [Activity]) {
        let withHumor = activities.filter { $0.result?.humor != nil }
        let grouped = Dictionary(grouping: withHumor) { $0.result!.humor }
        
        store?.presentFeelingsLoaded(feelings: grouped)
    }
}
