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
    
    // MARK: Steps .draw e .challenge (implementados em ActivityStore+Draw.swift)
    func displayChallenge(_ challenge: FrictionChallenge)
    func displaySearching()
    func displaySearchFailed()
    func displayAcceptedChallenge()
    func transitionToStart()
    func transitionToMood()
    func transitionToPhoto()
    
    // MARK: Step .photo
    func displayPhoto(_ photo: Image?)
    func displayCamera(isPresented: Bool)
    func displayFlashIcon(_ icon: String)
    func displayPermissionAlert(_ message: String?)
    func displayError(_ message: String?)
    
    // MARK: Transitions
    func transitionToInProgress()
    func transitionToDraw()
    func transitionToChallenge()
    func transitionToSummary()
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
    // Não são `private(set)` porque quem escreve é o `ActivityStore+Draw.swift`.
    // Extensions não podem ter propriedades armazenadas, por isso ficam aqui.
    
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

    // MARK: - Init
    
    init(coordinator: ActivityRouting) {
        self.coordinator = coordinator
    }
    
    // MARK: - Functions
    
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
    
    // MARK: Step .inProgress (cronômetro)

    /// Guarda o texto do tempo já formatado pelo Presenter.
    /// Como a Store é `@Observable`, a View que lê `timeText` se atualiza sozinha.
    func displayTimer(_ text: String) {
        timeText = text
    }
    
    // MARK: Transitions
    
    func transitionToInProgress() {
        self.coordinator.goToInProgress()
    }
    
    func transitionToDraw() {
        self.coordinator.goToDraw()
    }

    func transitionToChallenge() {
        self.coordinator.goToChallenge()
    }
    
    func transitionToSummary() {
        self.coordinator.goToSummary()
    }
    
    func finishFlow() {
        self.coordinator.finishFlow()
    }
    
}
