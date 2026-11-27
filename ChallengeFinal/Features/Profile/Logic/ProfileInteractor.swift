//
//  ProfileInteractor.swift
//  ChallengeFinal
//
//  Created by Raquel Souza on 16/10/26.
//

import Foundation
import PhotosUI
import SwiftUI

// MARK: - Protocol

/// O que a View enxerga do Interactor: só as AÇÕES que ela pode pedir.
protocol ProfileInteractorProtocol: AnyObject {
    // MARK: Carregamento
    func fetchProfile()
    // MARK: Edição (lápis)
    func startEditing()
    func saveEditing(name: String)
    func didSelectPhoto(_ item: PhotosPickerItem)
    // MARK: Temas
    func updateTheme(_ theme: Theme)
    // MARK: Configurações (engrenagem)
    func openSettings()
    func closeSettings()
    func updateNotifications(_ isOn: Bool)
    // MARK: Alertas
    func dismissAlerts()
}

// MARK: - Class

/// O "cérebro" da tela de Perfil.
///
/// Busca (ou cria) o único Profile do banco, calcula o streak a partir das
/// Activities concluídas, aplica o tema e cuida das permissões das configurações.
@MainActor
final class ProfileInteractor: ProfileInteractorProtocol {

    // MARK: - Dependências
    let presenter: ProfilePresenterProtocol
    let profileRepository: GenericRepository<Profile>
    let activityRepository: GenericRepository<Activity>
    let themeApplier: ThemeApplying
    let reminderScheduler: ReminderSchedulerServiceProtocol


    // MARK: - Estado interno

    /// Perfil carregado. Só existe um no app.
    private(set) var profile: Profile?

    // MARK: - Init

    init(presenter: ProfilePresenterProtocol,
         profileRepository: GenericRepository<Profile>,
         activityRepository: GenericRepository<Activity>,
         themeApplier: ThemeApplying,
         reminderScheduler: ReminderSchedulerServiceProtocol) {
        self.presenter = presenter
        self.profileRepository = profileRepository
        self.activityRepository = activityRepository
        self.themeApplier = themeApplier
        self.reminderScheduler = reminderScheduler
    }

    // MARK: - Carregamento

    /// Busca o perfil (cria o padrão se ainda não existir), recalcula o streak e aplica o tema salvo.
    func fetchProfile() {
        do {
            let profile = try loadOrCreateProfile()

            // Só contam atividades concluídas (com resultado registrado).
            let completedDates = try activityRepository.getAll()
                .filter { $0.result != nil }
                .map(\.createdAt)

            profile.streak = streak(from: completedDates)
            try profileRepository.save()
            
            themeApplier.currentTheme = profile.theme
            presenter.presentProfile(profile)
            presenter.presentTheme(profile.theme)

            // O toggle de notificações NÃO vem do `Profile`: vem da preferência guardada pelo Service.
            // Sem isso, a tela abriria sempre com o toggle desligado.
            presenter.presentSettings(notifications: reminderScheduler.isEnabled)
        } catch {
            presenter.presentError(error)
        }
    }

    // MARK: - Edição

    func startEditing() {
        presenter.presentEditing(isEditing: true, currentName: profile?.name ?? "")
    }

    /// Salva o nome digitado. Nome vazio mantém o anterior.
    func saveEditing(name: String) {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmed.isEmpty {
            profile?.name = trimmed
            save()
        }
        presenter.presentEditing(isEditing: false, currentName: profile?.name ?? "")
        presentCurrentProfile()
    }

    /// Foto escolhida na galeria. Os bytes podem demorar (ex.: iCloud).
    func didSelectPhoto(_ item: PhotosPickerItem) {
        _ = item.loadTransferable(type: Data.self) { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }
                do {
                    // `nil` = o item não devolveu os bytes da imagem.
                    guard let data = try result.get() else {
                        throw PhotoLibraryError.loadFailed
                    }
                    self.profile?.profilePicture = data
                    self.save()
                    self.presentCurrentProfile()
                } catch {
                    self.presenter.presentError(error)
                }
            }
        }
    }

    // MARK: - Temas

    func updateTheme(_ theme: Theme) {
        guard profile?.theme != theme else { return }
        profile?.theme = theme
        save()
        themeApplier.currentTheme = theme
        presenter.presentTheme(theme)
    }

    // MARK: - Configurações

    func openSettings() {
        presenter.presentSettingsSheet(isPresented: true)
    }

    func closeSettings() {
        presenter.presentSettingsSheet(isPresented: false)
    }

    /// O usuário mexeu no toggle de notificações das Configurações.
    ///
    /// FLUXO
    /// 1. A tela responde NA HORA: o toggle já mostra o valor pedido, antes de qualquer
    ///    coisa terminar (atualização otimista).
    /// 2. Em segundo plano, o Service pede a permissão (só ao ligar), grava a preferência e
    ///    agenda (ou cancela) os lembretes. O Interactor não conhece nada disso.
    /// 3. Quando o Service responde, o toggle é corrigido com o estado FINAL:
    ///    - ligou e concedeu → continua ligado;
    ///    - ligou e o usuário NEGOU a permissão → volta para desligado e abre o alerta
    ///      "libere as notificações nos Ajustes";
    ///    - desligou → fica desligado, sem alerta, e os lembretes pendentes são removidos.
    /// 4. Se o Service lançar erro, o toggle volta para desligado e o erro vai para o Presenter.
    ///
    /// Se o usuário ligar e desligar rápido, vale a última preferência gravada: o `refresh()`
    /// do Service sempre lê o valor atual antes de agendar.
    func updateNotifications(_ isOn: Bool) {
        presenter.presentSettings(notifications: isOn)

        Task { [weak self] in
            guard let self else { return }
            do {
                let enabled = try await reminderScheduler.setEnabled(isOn)
                presenter.presentSettings(notifications: enabled)
                if isOn && !enabled { presenter.presentNotificationsDenied() }
            } catch {
                presenter.presentSettings(notifications: false)
                presenter.presentError(error)
            }
        }
    }

    // MARK: - Alertas

    func dismissAlerts() {
        presenter.presentAlertsDismissed()
    }

    // MARK: - Regras de dias (estáticas para testar sem banco)

    /// Dias SEGUIDOS com desafio concluído, terminando hoje.
    /// Se hoje ainda não teve desafio, a sequência de ontem continua valendo.
     func streak(from dates: [Date], today: Date = Date(), calendar: Calendar = .current) -> Int {
        let days = Set(dates.map { calendar.startOfDay(for: $0) })
        var day = calendar.startOfDay(for: today)

        if !days.contains(day) {
            guard let yesterday = calendar.date(byAdding: .day, value: -1, to: day) else { return 0 }
            day = yesterday
        }

        var count = 0
        while days.contains(day) {
            count += 1
            guard let previous = calendar.date(byAdding: .day, value: -1, to: day) else { break }
            day = previous
        }
        return count
    }

    // MARK: - Auxiliares privados

     func loadOrCreateProfile() throws -> Profile {
        if let profile { return profile }

        if let saved = try profileRepository.getAll().first {
            profile = saved
            return saved
        }

        let newProfile = Profile()
        try profileRepository.add(newProfile)
        profile = newProfile
        return newProfile
    }

    /// Erro ao salvar também vira alerta (antes só ia para o console).
    private func save() {
        do {
            try profileRepository.save()
        } catch {
            presenter.presentError(error)
        }
    }

    /// Reapresenta o perfil sem recalcular o streak (ele não muda nesta tela).
    private func presentCurrentProfile() {
        guard let profile else { return }
        presenter.presentProfile(profile)
    }
}

