//
//  Group.swift
//  ChallengeFinal
//
//  Created by Débora Cristina Silva Ferreira on 19/10/26.
//

import Foundation
import SwiftUI
import SwiftData

// MARK: - Grupo de atividades
@Model
final class ActivityGroup {
    var groupId: UUID = UUID()
    var groupType: GroupType = GroupType.physical
    
    // Existe só para o CloudKit, ninguém fora da classe acessa
    @Relationship(inverse: \Activity.group)
    private var activities: [Activity]? = []
    
    var context: String = ""
    
    init(groupType: GroupType, context: String) {
        self.groupType = groupType
        self.context = context
    }

}
