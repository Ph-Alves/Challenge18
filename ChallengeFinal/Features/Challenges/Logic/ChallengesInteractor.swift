//
//  ChallengesInteractor.swift
//  ChallengeFinal
//
//  Created by Raquel Souza on 03/11/26.
//

import PhotosUI
import SwiftUI

protocol ChallengesInteractorProtocol: AnyObject {
    func loadChallenges()                             // tela apareceu: busca concluídos e arquivados
    func search(_ text: String)                       // digitou na busca
    func toggleCategory(_ category: ActivityCategory) // tocou num filtro (toca de novo para limpar)
    func openArchived()                               // botão de arquivados
    func closeArchived()                              // fechou o sheet (X ou arrastando)
    func restoreChallenge(_ activity: Activity)       // devolver o arquivado ao grupo
    func openSummary(_ activity: Activity)            // tocou num card: abre o resumo
    func closeSummary()                               //fechou o sheet de summary
    func shareStory()                                 // "compartilhar" no resumo
    func didFinishSharing(completed: Bool)            // share sheet fechou (concluiu ou cancelou)
    func dismissError()                               // fechou o alerta de erro
    // MARK: Câmera (tirar outra foto no resumo)
    func retakePhoto()                                // "tirar outra foto" no resumo
    func summaryDismissed()                           // onDismiss do sheet
    func cameraDismissed()                            // a câmera terminou de fechar
    func closeCamera()                                // X da câmera
    func toggleFlash()
    func switchCamera()
    func takePhoto()
    func didSelectFromGallery(_ item: PhotosPickerItem)
}

//MARK: - Class
final class ChallengesInteractor: ChallengesInteractorProtocol {
    
    // MARK: - Variables
    private let repository: GenericRepository<Activity>
    private let presenter: ChallengesPresenterProtocol
    private let share: ShareWorkerProtocol
    private let camera: CameraWorkerProtocol
    
    ///Estado dos filtros: guardado aqui para que, ao voltar para a tela (ou devolver um arquivado), a lista recalcule com os mesmos critérios.
    private(set) var searchText: String = ""
    private(set) var selectedCategory: ActivityCategory?
    
    // MARK: - Estado interno
    
    /// Desafio aberto no resumo. É dele que sai a imagem compartilhada.
    private(set) var selectedActivity: Activity?
    /// Flash ligado ou não. Regra de negócio, por isso fica aqui e não na Store.
    var isFlashOn = false
    /// `true` do toque em "tirar outra foto" até a câmera fechar. Serve para
    /// encadear sheet -> câmera -> sheet (a câmera só abre depois que o detalhe fecha).
    var isRetakingPhoto = false
    
    // MARK: - Init
    init(repository: GenericRepository<Activity>, presenter: ChallengesPresenterProtocol, share: ShareWorkerProtocol = ShareWorker(), camera: CameraWorkerProtocol = CameraWorker()) {
        self.repository = repository
        self.presenter = presenter
        self.share = share
        self.camera = camera
    }
    
    //MARK: - Functions
    
    func loadChallenges() {
        refreshCompleted()
        refreshArchived()
    }
    
    func search(_ text: String) {
        searchText = text
        refreshCompleted()
    }
    
    func toggleCategory(_ category: ActivityCategory) {
        selectedCategory = (selectedCategory == category) ? nil : category
        refreshCompleted()
    }
    
    //MARK: - Arquivados
    
    func openArchived() {
        refreshArchived()
        presenter.presentArchivedSheet(isPresented: true)
    }
    
    func closeArchived() {
        presenter.presentArchivedSheet(isPresented: false)
    }
    
    ///lembrando que aqui nessa função eu to tirando a activity dos arquivados
    func restoreChallenge(_ activity: Activity) {
        guard activity.archived else { return }
 
        do {
            try repository.delete(activity)
        } catch {
            presenter.presentError("não foi possível devolver o desafio. tente de novo.")
        }
        refreshArchived()
    }
    
    //MARK: - Summary
    
    func openSummary(_ activity: Activity) {
        // Guardado aqui porque o `shareStory()` gera a imagem a partir dele.
        selectedActivity = activity
        presenter.presentSummary(activity)
    }
    
    /// O usuário fechou o resumo (X ou arrastando). Se o resumo saiu para a câmera abrir,
    /// o desafio continua selecionado: ele volta quando a câmera fechar.
    func closeSummary() {
        if !isRetakingPhoto {
            selectedActivity = nil
        }
        presenter.presentSummary(nil)
    }
    
    //MARK: - Compartilhar
    
    /// A imagem não aparece na tela: é só o arquivo que vai para o share sheet,
    /// então é gerada aqui, na hora do toque, e não fica guardada na Store.
    func shareStory() {
        guard let selectedActivity, let image = makeStoryImage(for: selectedActivity) else {
            presenter.presentError("não foi possível preparar a imagem para compartilhar.")
            return
        }
        
        do {
            let fileURL = try share.makeShareFile(from: image)
            presenter.presentShareSheet(fileURL: fileURL)
        } catch {
            presenter.presentError("não foi possível preparar a imagem para compartilhar.")
        }
    }
    
    func didFinishSharing(completed: Bool) {
        presenter.presentShareFinished(completed: completed)
    }
    
    func dismissError() {
        presenter.presentError(nil)
    }
    
    
    // MARK: - Câmera (tirar outra foto)
  
     /// Toque em "tirar outra foto". Verifica a permissão toda vez, porque
     /// o usuário pode ter mudado nos Ajustes no meio do caminho.
     ///
     /// Com a permissão OK, só fecha o resumo. A câmera abre em `summaryDismissed()`,
     /// quando o sheet terminou de fechar: apresentar as duas coisas ao mesmo tempo falha.
     func retakePhoto() {
         switch camera.permissionStatus() {
         case .authorized:
             hideSummaryForCamera()
             
         case .notDetermined:
             camera.requestPermission { [weak self] granted in
                 guard let self else { return }
                 
                 if granted {
                     self.hideSummaryForCamera()
                 } else {
                     self.presenter.presentPermissionDenied()
                 }
             }
         case .denied:
             presenter.presentPermissionDenied()
         }
     }
  
     /// O sheet do resumo terminou de fechar. Se foi para tirar outra foto, agora a câmera abre.
     func summaryDismissed() {
         guard isRetakingPhoto else { return }
         startCamera()
     }
  
     /// A câmera terminou de fechar (com foto nova ou sem): o resumo volta.
     func cameraDismissed() {
         guard isRetakingPhoto else { return }
         isRetakingPhoto = false
  
         guard let selectedActivity else { return }
         presenter.presentSummary(selectedActivity)
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
                 self.presenter.presentCameraError(error)
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
                 self.presenter.presentCameraError(error)
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
                     self.presenter.presentCameraError(error)
                 }
             }
         }
     }
    
    
    //MARK: - Private Functions
    
    private func hideSummaryForCamera() {
        isRetakingPhoto = true
        presenter.presentSummary(nil)
    }
 
    private func startCamera() {
        presenter.presentFlash(isOn: isFlashOn)
        presenter.presentCamera(isPresented: true)
 
        camera.startSession { [weak self] result in
            guard let self else { return }
 
            do {
                try result.get()
            } catch {
                // A câmera não ligou: fecha a tela e mostra o erro.
                self.camera.stopSession()
                self.presenter.presentCameraClosed()
                self.presenter.presentCameraError(error)
            }
        }
    }
 
    /// Caminho comum para foto da câmera e da galeria: salva no desafio e fecha a câmera.
    /// O resumo volta com a foto nova em `cameraDismissed()`.
    private func didReceivePhoto(_ data: Data) {
        camera.stopSession()
        
        // Guarda a foto antiga: se o banco falhar, a tela não pode mostrar uma foto que não foi salva.
        let oldPhoto = selectedActivity?.result?.photo
        
        do {
            selectedActivity?.result?.photo = data
            try repository.save()
        } catch {
            selectedActivity?.result?.photo = oldPhoto
            presenter.presentCameraClosed()
            presenter.presentError("não foi possível salvar a nova foto. tente de novo.")
            return
        }
        
        presenter.presentCameraClosed()
        // A foto do card na grade também muda.
        refreshCompleted()
    }
    
    
    /// Monta o StoryCard e transforma em UIImage. `nil` = a renderização falhou.
    private func makeStoryImage(for activity: Activity) -> UIImage? {
        let name = activity.name.trimmingCharacters(in: .whitespacesAndNewlines)
        let photo = activity.result?.photo.flatMap { UIImage(data: $0) }
 
        let story = StoryCard(
            challengeTitle: name.isEmpty ? "desafio concluído" : name,
            challengeDescription: activity.activityDescription.trimmingCharacters(in: .whitespacesAndNewlines),
            challengePhoto: photo, challengeIcon: activity.category.closedIcon
        )
        return ShareImageRenderer.render(story)
    }
    
    ///a primeira função será a de carregar os challenges já feitos.
    private func completedActivities() throws -> [Activity] {
        try repository.getAll()
            .filter { !$0.archived }
            .sorted { $0.createdAt > $1.createdAt }
    }
    
    private func refreshCompleted() {
        do {
            let completed = try completedActivities()
            let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)

            let filtered = completed
                .filter { selectedCategory == nil || $0.category == selectedCategory }
                // Ignora maiúsculas e acentos
                .filter { query.isEmpty || $0.name.localizedStandardContains(query) }

            presenter.presentChallenges(filtered, selectedCategory: selectedCategory,hasCompletedChallenges: !completed.isEmpty)
        } catch {
            presenter.presentError("não foi possível carregar seus desafios.")
        }
    }
    
    
    private func refreshArchived() {
        do {
            let archived = try repository.getAll()
                .filter(\.archived)
//                .sorted { $0.createdAt > $1.createdAt } //CHANGE: descomentar após o ph inserir a data de criação na model
            presenter.presentArchivedChallenges(archived)
        } catch {
            presenter.presentError("não foi possível carregar os arquivados.")
        }
    }
    
}
