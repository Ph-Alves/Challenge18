//
//  Activity.swift
//  ChallengeFinal
//
//  Created by Raquel Souza on 16/10/26.
//

import SwiftData
import Foundation

// MARK: - Atividade realizada opelo usuario
@Model
final class Activity {
    var activityID: UUID = UUID()
    
    var category: ActivityCategory = ActivityCategory.physical
    
    @Relationship(deleteRule: .cascade, inverse: \ActivityResult.activity)
    var result: ActivityResult?
    
    var name: String = ""
    
    var activityDescription: String = ""
    
    var archived: Bool = false
    
    init(category: ActivityCategory, result: ActivityResult?, name: String, description: String, archived: Bool) {
        self.category = category
        self.result = result
        self.name = name
        self.activityDescription = description
        self.archived = archived
    }
}
