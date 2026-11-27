//
//  ProfileBuilder.swift
//  ChallengeFinal
//
//  Created by Raquel Souza on 16/10/26.
//

import Foundation
import SwiftData

///
/// É o ÚNICO lugar que conhece as classes concretas. Todo o resto se enxerga por protocolo.
/// Ordem de criação: Store -> Presenter(store) -> Interactor(presenter, repositórios) -> View
enum ProfileBuilder {
    @MainActor
    static func build(context: ModelContext) -> ProfileView {
        let store = ProfileStore()
        let presenter = ProfilePresenter(store: store)
        let reminderScheduler = ReminderSchedulerService(
            preferences: PreferencesWorker(),
            activityRepository: GenericRepository<Activity>(context: context),
            notifications: NotificationWorker()
        )
        let interactor = ProfileInteractor(
            presenter: presenter,
            profileRepository: GenericRepository<Profile>(context: context),
            activityRepository: GenericRepository<Activity>(context: context),
            ///Tem que ser o .shared, e não um DesignSystem() novo, por dois motivos.
            ///Primeiro, o init dele é private, então nem compila.
            ///Segundo, é essa instância única que está no .environment(DesignSystem.shared) do MyApp.
            ///Quando o Interactor muda o currentTheme, todas as Views que leem o designSystem do environment são atualizadas.
            ///Com qualquer outra instância, o tema seria salvo, mas a tela não mudaria.
            themeApplier: DesignSystem.shared,
            reminderScheduler: reminderScheduler

        )

        // A View segura a Store com força: o Presenter guarda a Store como `weak`.
        return ProfileView(interactor: interactor, store: store)
    }
}
