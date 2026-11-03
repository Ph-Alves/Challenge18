//
//  FeelingsInteractor.swift
//  ChallengeFinal
//
//  Created by Paulo Henrique Costa Alves on 02/11/26.
//

import Foundation
import PhotosUI
import SwiftUI

// MARK: - Protocol

/// O que a View enxerga do Interactor: só as AÇÕES que ela pode pedir.
///
/// Com o protocolo, a View não depende da classe concreta. Nos testes e nos
/// `#Preview`, dá para passar um Interactor falso.
protocol FeelingsInteractorProtocol: AnyObject {
    // MARK: Carregamento
    func loadFeelings()
    func selectActivity(activity: Activity)
    func deleteActivity(activity: Activity)
    // MARK: Câmera
    func retakePhoto()
    func closeCamera()
    func toggleFlash()
    func switchCamera()
    func takePhoto()
    func didSelectFromGallery(_ item: PhotosPickerItem)
    func dismissAlerts()
    // MARK: Compartilhar
    func shareStory(_ image: UIImage?)
    func didFinishSharing(completed: Bool)
}

// MARK: - Class

/// O "cérebro" da tela de Feelings.
///
/// Busca as Activities no banco, decide quais entram na conta e avisa o
/// Presenter do resultado.
///
/// Organização (por seção, em ordem): dependências e init, carregamento dos
/// sentimentos, câmera (tirar outra foto) e compartilhar.
@MainActor
final class FeelingsInteractor: FeelingsInteractorProtocol {
    
    // MARK: - Dependências
    
    /// Para quem o Interactor manda os resultados. Pelo protocolo, para dar spy nos testes.
    let presenter: FeelingsPresenterProtocol
    
    /// Acesso às Activities salvas no banco.
    let activityRepository: GenericRepository<Activity>
    
    /// Câmera usada para trocar a foto de uma atividade.
    let camera: CameraWorkerProtocol
    
    /// Grava a imagem do story em PNG para o share sheet.
    let share: ShareWorkerProtocol
    
    // MARK: - Estado interno
    
    /// Atividade aberta no detalhe: é a dona da foto que será trocada.
    var selectedActivity: Activity?
    
    /// Flash ligado ou não. Regra de negócio, por isso fica aqui e não na Store.
    var isFlashOn = false
    
    // MARK: - Init
    
    init(presenter: FeelingsPresenterProtocol, activityRepository: GenericRepository<Activity>, camera: CameraWorkerProtocol = CameraWorker(), share: ShareWorkerProtocol = ShareWorker()) {
        self.presenter = presenter
        self.activityRepository = activityRepository
        self.camera = camera
        self.share = share
    }

    // MARK: - Carregamento

    /// Busca as Activities do banco e manda para o Presenter.
    /// Só entram as que têm `result`: sem resultado, o usuário não chegou a
    /// registrar o humor, então não contam nos sentimentos.
    func loadFeelings() {
        do {
            let activities = try self.activityRepository.getAll().filter { $0.result != nil }
            presenter.presentFeelingsLoaded(activities: activities)
        } catch {
            print("Erro ao buscar atividades: \(error.localizedDescription)")
        }
    }
    
    func selectActivity(activity: Activity) {
        selectedActivity = activity
        presenter.presentSelectedActivity(activity: activity)
    }
    
    func deleteActivity(activity: Activity) {
        do {
            try activityRepository.delete(activity)
            loadFeelings()
        } catch {
            print("Erro ao deletar atividade: \(error.localizedDescription)")
        }
    }

    // MARK: - Câmera (tirar outra foto)

    /// Toque em "tirar outra foto". Verifica a permissão toda vez, porque
    /// o usuário pode ter mudado nos Ajustes no meio do caminho.
    func retakePhoto() {
        switch camera.permissionStatus() {
        case .authorized:
            startCamera()
            
        case .notDetermined:
            camera.requestPermission { [weak self] granted in
                guard let self else { return }
                
                if granted {
                    self.startCamera()
                } else {
                    self.presenter.presentPermissionDenied()
                }
            }
            
        case .denied:
            presenter.presentPermissionDenied()
        }
    }
    
    /// O usuário fechou a câmera sem tirar foto: a foto antiga continua.
    func closeCamera() {
        camera.stopSession()
        presenter.presentCameraClosed()
    }
    
    func toggleFlash() {
        isFlashOn.toggle()
        presenter.presentFlash(isOn: isFlashOn)
    }
    
    func switchCamera() {
        camera.switchCamera { [weak self] result in
            guard let self else { return }
            
            do {
                try result.get()
            } catch {
                self.presenter.presentError(error)
            }
        }
    }
    
    func takePhoto() {
        camera.capturePhoto(flash: isFlashOn) { [weak self] result in
            guard let self else { return }
            
            do {
                let data = try result.get()
                self.didReceivePhoto(data)
            } catch {
                self.presenter.presentError(error)
            }
        }
    }
    
    /// Foto escolhida na biblioteca. Os bytes precisam ser carregados (pode demorar, ex.: iCloud).
    func didSelectFromGallery(_ item: PhotosPickerItem) {
        _ = item.loadTransferable(type: Data.self) { [weak self] result in
            // O sistema responde numa fila qualquer: voltamos para a main.
            DispatchQueue.main.async {
                guard let self else { return }
                
                do {
                    guard let data = try result.get() else {
                        throw PhotoLibraryError.loadFailed
                    }
                    self.didReceivePhoto(data)
                } catch {
                    self.presenter.presentError(error)
                }
            }
        }
    }
    
    func dismissAlerts() {
        presenter.presentAlertsDismissed()
    }
    
    // MARK: Auxiliares privados

    private func startCamera() {
        presenter.presentFlash(isOn: isFlashOn)
        presenter.presentCamera()
        
        camera.startSession { [weak self] result in
            guard let self else { return }
            
            do {
                try result.get()
            } catch {
                // A câmera não ligou: fecha a tela e mostra o erro.
                self.camera.stopSession()
                self.presenter.presentCameraClosed()
                self.presenter.presentError(error)
            }
        }
    }
    
    /// Caminho comum para foto da câmera e da galeria: salva na atividade e avisa o Presenter.
    private func didReceivePhoto(_ data: Data) {
        camera.stopSession()
        
        do {
            selectedActivity?.result?.photo = data
            try activityRepository.save()
        } catch {
            print("Erro ao salvar a nova foto: \(error.localizedDescription)")
            presenter.presentError(error)
            presenter.presentCameraClosed()
            return
        }
        presenter.presentPhotoUpdated(data)
        
        // O story usa a foto: gera de novo com a nova.
        if let selectedActivity {
            presenter.presentStory(for: selectedActivity)
        }
    }

    // MARK: - Compartilhar

    /// Toque em "compartilhar". `nil` = a renderização falhou: mostramos o erro
    /// em vez de abrir um sheet vazio.
    func shareStory(_ image: UIImage?) {
        guard let image else {
            presenter.presentError(ShareError.renderFailed)
            return
        }
        
        do {
            let fileURL = try share.makeShareFile(from: image)
            presenter.presentShareSheet(fileURL: fileURL)
        } catch {
            presenter.presentError(error)
        }
    }
    
    /// O share sheet fechou (concluiu ou cancelou).
    func didFinishSharing(completed: Bool) {
        presenter.presentShareFinished(completed: completed)
    }
}
