//
//  ProfilePresenter.swift
//  ChallengeFinal
//
//  Created by Raquel Souza on 16/10/26.
//

import SwiftUI

// MARK: - Protocol

/// O que o Interactor enxerga do Presenter (spy nos testes).
protocol ProfilePresenterProtocol: AnyObject {
    // MARK: Tela de perfil
    func presentProfile(_ profile: Profile)
    func presentTheme(_ theme: Theme)
    func presentEditing(isEditing: Bool, currentName: String)
    // MARK: Sheet de configurações
    func presentSettingsSheet(isPresented: Bool)
    // MARK: Alertas
    func presentLocationDenied()
    func presentNotificationsDenied()
    func presentError(_ error: Error)
    func presentAlertsDismissed()
}

//MARK: - Class
@MainActor
final class ProfilePresenter: ProfilePresenterProtocol {

    // MARK: - Variables

    /// Fraca para não criar ciclo com a Store.
    weak var store: ProfileStoreProtocol?

    // MARK: - Init
    //injeção de dependência pelo ini
    init(store: ProfileStoreProtocol) {
        self.store = store
    }

    // MARK: - Tela de perfil

    /// Nome, foto, streak e configurações.
    func presentProfile(_ profile: Profile) {
        store?.displayProfile(
            name: profile.name.isEmpty ? "nome" : profile.name,
            userPhoto: image(from: profile.profilePicture)
        )

        let milestone = Self.milestone(for: profile.streak)
        store?.displayStreak(
            streakText: Self.streakText(for: profile.streak),
            levelTitle: milestone.title,
            levelSubtitle: milestone.message
        )

        store?.displaySettings(
            localizable: profile.localizable,
            notifications: profile.notifications,
            backgroundActivity: profile.backgroundActivity
        )
    }

    /// O tema não precisa de formatação, só é repassado.
    func presentTheme(_ theme: Theme) {
        store?.displayTheme(theme)
    }

    func presentEditing(isEditing: Bool, currentName: String) {
        store?.displayEditing(isEditing: isEditing, draftName: currentName)
    }

    // MARK: - Sheet de configurações

    func presentSettingsSheet(isPresented: Bool) {
        store?.displaySettingsSheet(isPresented: isPresented)
    }

    // MARK: - Alertas

    /// Vai para o alerta de permissão, que tem o botão "abrir ajustes".
    func presentLocationDenied() {
        store?.displayPermissionAlert(
            "Para receber desafios perto de você, libere a localização nos Ajustes."
        )
    }

    func presentNotificationsDenied() {
        store?.displayPermissionAlert(
            "Para ser lembrado dos desafios, libere as notificações nos Ajustes."
        )
    }

    /// O Interactor só repassa o erro; escolher o texto é papel do Presenter.
    func presentError(_ error: Error) {
        let message: String

        switch error {
        case PhotoLibraryError.loadFailed:
            message = "Não foi possível carregar a foto. Tente outra."
        default:
            message = "Algo deu errado. Tente novamente."
        }

        store?.displayError(message)
    }

    /// O usuário fechou o alerta (de permissão ou de erro).
    func presentAlertsDismissed() {
        store?.displayPermissionAlert(nil)
        store?.displayError(nil)
    }

    // MARK: - Streak

    /// cada uma vale a partir do dia do marco.
    /// Ordem crescente; a última vale para sempre depois dela.
    static let milestones: [(day: Int, title: String, message: String)] = [
        (0,  "começando :)",          "o primeiro passo você já deu, agora falta se desafiar!"),
        (3,  "pegou o ritmo",         "03 dias cuidando de você, continue assim!"),
        (7,  "lenda da consistência", "07 dias priorizando seu bem estar!"),
        (15, "virou rotina",          "15 dias provando que você consegue!"),
        (20, "nova era?",             "estamos sem palavras com essa constância XD"),
        (30, "ícone faz assim!",      "um mês inteiro de você em primeiro lugar <3")
    ]

    /// O último marco que o usuário já alcançou (ex.: 5 dias -> variante dos 3 dias).
    static func milestone(for streak: Int) -> (title: String, message: String) {
        let reached = milestones.last { streak >= $0.day } ?? milestones[0]
        return (reached.title, reached.message)
    }

    /// "0 dias", "03 dias", "15 dias" (dois dígitos).
    static func streakText(for streak: Int) -> String {
        streak == 0 ? "0 dias" : String(format: "%02ld %@", streak, streak == 1 ? "dia" : "dias")
    }

    // MARK: - Auxiliares

    /// `Data` (bytes) -> `Image`. `nil` se não houver foto ou os bytes forem inválidos.
    private func image(from data: Data?) -> Image? {
        guard let data, let uiImage = UIImage(data: data) else { return nil }
        return Image(uiImage: uiImage)
    }
}

