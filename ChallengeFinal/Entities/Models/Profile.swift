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
    var localizable: Bool = false          // "sua localizaçõ no prototipo"
    var theme: Theme = Theme.sober
    var backgroundActivity: Bool = false
    var streak: Int = 0
    
    //para o interactor não ter que inventar dados na primeira vez que o usuário abre o app, vou colocar valores padroes. Profile() já vai ser o perfil inicial.
    init(profilePicture: Data? = nil, name: String = "", notifications: Bool = false, localizable: Bool = false, theme: Theme = .sober, backgroundActivity: Bool = false, streak: Int = 0) {
        self.profilePicture = profilePicture
        self.name = name
        self.notifications = notifications
        self.localizable = localizable
        self.theme = theme
        self.backgroundActivity = backgroundActivity
        self.streak = streak
    }
}
