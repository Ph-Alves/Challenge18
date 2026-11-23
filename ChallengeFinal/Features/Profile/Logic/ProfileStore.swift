//
//  ProfileStore.swift
//  ChallengeFinal
//
//  Created by Raquel Souza on 17/11/26.
//

import SwiftUI


//MARK: - Protocol
@MainActor
protocol ProfileStoreProtocol: AnyObject {
    func displayProfile(name: String, userPhoto: Image?)
    func displayStreak(streakText: String, levelTitle: String, levelSubtitle: String)
    func displaySettings(localizable: Bool, notifications: Bool, backgroundActivity: Bool)
    func displaySettingsSheet(isPresented: Bool)
    func displayEditing(isEditing: Bool, draftName: String)
    func displayTheme(_ theme: Theme)
    // alertas
    func displayPermissionAlert(_ message: String?)
    func displayError(_ message: String?)
}

//MARK: - Class
@MainActor
@Observable
final class ProfileStore: ProfileStoreProtocol {
    
    //MARK: - Variables
    
    //MARK: Perfil
    private(set) var name = "nome"
    private(set) var userPhoto: Image?
    
    //MARK: Streak
    private(set) var streakText = "0 dias"               
    private(set) var levelTitle = "começando :)"
    private(set) var levelSubtitle = "o primeiro passo você já deu, agora falta se desafiar!"
    
    //MARK: Settings
    private(set) var localizable = false
    private(set) var notifications = false
    private(set) var backgroundActivity = false
    var isSettingsPresented = false
    
    //MARK: Edit Mode
    private(set) var isEditing = false
    var draftName = ""
    
    //MARK: Alerts
    /// Permissão negada (tem o botão "abrir ajustes").
    private(set) var permissionAlertMessage: String?
    /// Erro técnico (só "OK").
    private(set) var errorMessage: String?
    
    // MARK: Theme
    let themes: [Theme] = [.sober, .pop] //por enquanto é um array pois temos só esses dois no prototipo de alta, quando tiver todos, podemos usar apenas o enum direto na view
    private(set) var currentTheme: Theme = .sober
    
    //MARK: - Functions
    func displayProfile(name: String, userPhoto: Image?) {
        self.name = name
        self.userPhoto = userPhoto
    }
    
    func displayStreak(streakText: String, levelTitle: String, levelSubtitle: String) {
        self.streakText = streakText
        self.levelTitle = levelTitle
        self.levelSubtitle = levelSubtitle
    }
    
    func displaySettings(localizable: Bool, notifications: Bool, backgroundActivity: Bool) {
        self.localizable = localizable
        self.notifications = notifications
        self.backgroundActivity = backgroundActivity
    }

    func displaySettingsSheet(isPresented: Bool) {
        self.isSettingsPresented = isPresented
    }
    
    func displayEditing(isEditing: Bool, draftName: String) {
        self.isEditing = isEditing
        self.draftName = draftName
    }
    
    func displayTheme(_ theme: Theme) {
        self.currentTheme = theme
    }
    
    func displayPermissionAlert(_ message: String?) {
        self.permissionAlertMessage = message
    }

    func displayError(_ message: String?) {
        self.errorMessage = message
    }
}
