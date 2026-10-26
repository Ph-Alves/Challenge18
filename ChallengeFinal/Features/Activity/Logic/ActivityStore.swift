//
//  ActivityStore.swift
//  ChallengeFinal
//
//  Created by Raquel Souza on 23/10/26.
//

///apenas dados. A View só lê o meu Store e o Presenter escreve nele.

import SwiftUI

//MARK: - Protocolo
protocol ActivityStoreProtocol: AnyObject {
    
    // MARK: Step .photo
    func displayPhoto(_ photo: Image?)
    func displayCamera(isPresented: Bool)
    func displayFlashIcon(_ icon: String)
    func displayPermissionAlert(_ message: String?)
    func displayError(_ message: String?)
}

//// MARK: - ViewModels
//
///// Tudo que a tela de foto precisa mostrar, já pronto para exibir.
///// Quem monta é o Presenter; a Store guarda; a View só lê.
//struct PhotoStepViewModel {
//    /// A foto escolhida. `nil` = card vazio (tela inicial).
//    var photo: Image?
//    /// "tire uma foto!" ou "tirar outra foto".
//    var captureButtonTitle: String
//    /// SF Symbol do botão: "camera.fill" ou "arrow.clockwise".
//    var captureButtonIcon: String
//    /// "continuar sem foto" ou "continuar".
//    var continueButtonTitle: String
//}
//
//extension PhotoStepViewModel {
//    /// Estado inicial, antes de qualquer foto.
//    static let empty = PhotoStepViewModel(
//        photo: nil,
//        captureButtonTitle: "tire uma foto!",
//        captureButtonIcon: "camera.fill",
//        continueButtonTitle: "continuar sem foto"
//    )
//}


//MARK: - Store

@MainActor
@Observable
final class ActivityStore: ActivityStoreProtocol {
 
    // MARK: - Variables
 
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
 
    // MARK: Outros steps
    // Cada step adiciona aqui as suas propriedades (sempre `private(set)`).
 
    // MARK: - Init
 
    deinit {
        print("ActivityStore liberado")
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
 
    // MARK: Outros steps
    // Cada step adiciona aqui os seus métodos `display...` (e no protocolo acima).
}
