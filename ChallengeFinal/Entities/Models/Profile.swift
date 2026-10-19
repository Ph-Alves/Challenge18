//
//  Profile.swift
//  ChallengeFinal
//
//  Created by Raquel Souza on 16/10/26.
//
import SwiftData
import Foundation
import SwiftUI

// MARK: - Model do perfil do usuário
@Model
final class Profile {
    var profileID: UUID = UUID()
    @Attribute(.externalStorage) var profilePicture: Data?
    var name: String = ""
    var notifications: Bool = false
    var theme: Theme = Theme.themeOne
    var backgroundActivity: Bool = false
    var streak: Int = 0
    
    init(profilePicture: Data, name: String, notifications: Bool, theme: Theme, backgroundActivity: Bool, streak: Int) {
        self.profilePicture = profilePicture
        self.name = name
        self.notifications = notifications
        self.theme = theme
        self.backgroundActivity = backgroundActivity
        self.streak = streak
    }
}
