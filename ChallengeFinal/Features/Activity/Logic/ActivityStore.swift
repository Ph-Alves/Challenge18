//
//  ActivityStore.swift
//  ChallengeFinal
//
//  Created by Paulo Henrique Costa Alves on 23/10/26.
//

import Foundation
import SwiftData
import SwiftUI

// MARK: - Protocol
/// O que o Presenter enxerga da Store: métodos `display...` (dados prontos
/// para a tela) e `transitionTo...` (mudança de step).
protocol ActivityStoreProtocol: AnyObject {
    // MARK: - Step do timer
    func displayTimer(_ text: String)
    
    // MARK: Steps .draw e .challenge
    func displayActivity(_ challenge: FrictionChallenge)
    func displaySearching()
    func displaySearchFailed()
    func displayAcceptedActivity()
    func displayRestoredChallenge(title: String, subtitle: String, description: String)
    func transitionToStart()
    func transitionToMood()
    func transitionToPhoto()
    
    //MARK: Step .humor
    func displayHumor(_ humor: Humor)
    
    // MARK: Step .photo
    func displayPhoto(_ photo: Image?)
    func displayCamera(isPresented: Bool)
    func displayFlashIcon(_ icon: String)
    func displayPermissionAlert(_ message: String?)
    func displayError(_ message: String?)
    
    // MARK: Step .summary
    func displayStoryImage(_ image: UIImage?)
    func displayShareSheet(_ item: ShareItem?)
    
    // MARK: Transitions
    func transitionToInProgress()
    func transitionToDraw()
    func transitionToActivity()
    func transitionToSummary(achievement: Achievement)
    func finishFlow()
}

//MARK: - Class
/// Estado da tela de Activity. A View só LÊ daqui; quem escreve é o Presenter.
/// As propriedades são `private(set)` para garantir esse sentido único.
/// Também repassa as transições de step ao Coordinator.
@MainActor
@Observable
final class ActivityStore: ActivityStoreProtocol {
    
    // MARK: - Variables
    
    /// Coordinator para navegação
    let coordinator: ActivityRouting
    
    // MARK: Steps .draw e .challenge
    /// Desafio sorteado (título, subtítulo e descrição). `nil` = ainda não sorteou.
    var activityTitle: String?
    var activitySubtitle: String?
    var activityDescription: String?
    
    /// Está procurando um desafio.
    var isSearching = false
    
    /// O desafio ficou pronto: a View anima a bola e só depois avança de step.
    var isChallengeReady = false
    
    /// O usuário aceitou o desafio (o step `.challenge` mostra a tela de aceito).
    var isChallengeAccepted = false
    
    
    //MARK: Step .Humor
    
    /// Humor registrado
    private(set) var humor: Humor = .chill
    
    // MARK: Step .photo
    
    /// A foto escolhida. `nil` = card vazio (tela inicial).
    private(set) var photo: Image?
 
    /// Controla a `fullScreenCover` da câmera (tela preta).
    private(set) var isCameraPresented: Bool = false
 
    /// SF Symbol do botão de flash na câmera: "bolt.slash" (desligado) ou "bolt.fill" (ligado).
    private(set) var cameraFlashIcon: String = "bolt.slash"
 
    /// Mensagem quando a permissão de câmera é negada. `nil` = sem alerta.
    private(set) var permissionAlertMessage: String?
 
    /// Mensagem de erro (ex.: falha na captura). `nil` = sem erro.
    private(set) var errorMessage: String?
    
    /// Tempo do cronômetro já formatado ("hh:mm:ss").
    /// O Presenter escreve a cada tick; a View só lê.
    private(set) var timeText: String = "00:00:00"
    
    /// Step atual, vindo do Coordinator. Por ser @Observable, a View
    /// é redesenhada quando ele muda.
    var currentStep: ActivityStep {
        return self.coordinator.step
    }
    
    //MARK: Step .summary
    
    /// Título da conquista (ex.: "mestre offline"). `nil` = o summary ainda não abriu.
    /// Chega junto com a transição para o summary (`transitionToSummary`).
    private(set) var achievementTitle: String?

    /// Descrição da conquista, já citando o tempo da atividade. `nil` = o summary ainda não abriu.
    private(set) var achievementDescription: String?
    
    /// Imagem do story já renderizada, pronta para o "compartilhar".
    /// `nil` = a renderização falhou; o Interactor trata ao tocar em compartilhar.
    private(set) var storyImage: UIImage?
    
    /// Controla o `.sheet(item:)` do share sheet. `nil` = fechado.
    private(set) var shareItem: ShareItem?

    // MARK: - Init
    
    init(coordinator: ActivityRouting) {
        self.coordinator = coordinator
    }
    
    // MARK: - Functions
    
    // MARK: Step .humor
    
    func displayHumor(_ humor: Humor) {
        self.humor = humor
    }
    
    // MARK: Step .photo
 
    func displayPhoto(_ photo: Image?) {
        self.photo = photo
    }
 
    func displayCamera(isPresented: Bool) {
        isCameraPresented = isPresented
    }
 
    func displayFlashIcon(_ icon: String) {
        cameraFlashIcon = icon
    }
 
    func displayPermissionAlert(_ message: String?) {
        permissionAlertMessage = message
    }
 
    func displayError(_ message: String?) {
        errorMessage = message
    }
    
    
    // MARK: Step .summary
    
    func displayStoryImage(_ image: UIImage?) {
        storyImage = image
    }

    func displayShareSheet(_ item: ShareItem?) {
        shareItem = item
    }
    
    // MARK: Step .inProgress (cronômetro)

    /// Guarda o texto do tempo já formatado pelo Presenter.
    /// Como a Store é `@Observable`, a View que lê `timeText` se atualiza sozinha.
    func displayTimer(_ text: String) {
        timeText = text
    }
    
    // MARK: Steps .draw e .challenge
    // Os requisitos estão declarados no `ActivityStoreProtocol`.

    /// Guarda o desafio sorteado e marca como pronto.
    func displayActivity(_ challenge: FrictionChallenge) {
        self.activityTitle = challenge.title
        self.activitySubtitle = challenge.subTitle
        self.activityDescription = challenge.rationale
        self.isSearching = false
        // A view anima a bola e só depois chama transitionToChallenge()
        self.isChallengeReady = true
    }

    /// Também desfaz o "aceito": um novo sorteio (reroll) volta para a tela do desafio.
    func displaySearching() {
        self.isSearching = true
        self.isChallengeAccepted = false
    }

    func displaySearchFailed() {
        self.isSearching = false
    }

    func displayAcceptedActivity() {
        self.isChallengeAccepted = true
    }

    /// Só guarda os textos do desafio (o app foi relançado depois do sorteio).
    /// Não mexe em `isChallengeReady` nem em `isSearching`: a View não anima a bola de novo.
    func displayRestoredChallenge(title: String, subtitle: String, description: String) {
        self.activityTitle = title
        self.activitySubtitle = subtitle
        self.activityDescription = description
    }

    // MARK: Transitions

    /// Volta para o sorteio já com o estado limpo, para gerar um novo desafio.
    func transitionToStart() {
        self.isSearching = false
        self.isChallengeReady = false
        self.isChallengeAccepted = false
        self.coordinator.goToChallenge()
    }

    func transitionToMood() {
        self.coordinator.goToMood()
    }

    func transitionToPhoto() {
        self.coordinator.goToPhoto()
    }

    func transitionToInProgress() {
        self.coordinator.goToInProgress()
    }
    
    func transitionToDraw() {
        self.coordinator.goToDraw()
    }

    func transitionToActivity() {
        self.coordinator.goToChallenge()
    }
    
    /// Guarda a conquista e só então troca o step, para o summary já abrir com os textos.
    func transitionToSummary(achievement: Achievement) {
        self.achievementTitle = achievement.title
        self.achievementDescription = achievement.description
        self.coordinator.goToSummary()
    }
    
    func finishFlow() {
        self.coordinator.finishFlow()
    }
}
