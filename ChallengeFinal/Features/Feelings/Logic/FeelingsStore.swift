//
//  FeelingsStore.swift
//  ChallengeFinal
//
//  Created by Paulo Henrique Costa Alves on 02/11/26.
//

import SwiftUI


// MARK: - Protocol

/// O que o Presenter enxerga da Store: dados prontos para a tela.
protocol FeelingsStoreProtocol: AnyObject {
    // MARK: Carregamento
    func presentFeelingsLoaded(feelings: [Humor: [(activity: Activity, image: Image?)]])
    func presentActivityDetails(activity: Activity, photo: Image?)
    func returnToFeelings()
    // MARK: Câmera
    func presentCamera(isPresented: Bool)
    func presentFlashIcon(_ icon: String)
    func presentError(_ message: String?)
    func presentPhoto(_ photo: Image?)
    func presentDetailVisibility(isVisible: Bool)
    // MARK: Compartilhar
    func presentStoryImage(_ image: UIImage?)
    func presentShareSheet(_ item: ShareItem?)
}

// MARK: - Class

/// Estado da tela de Feelings. A View só LÊ daqui; quem escreve é o Presenter.
@MainActor
@Observable
final class FeelingsStore: FeelingsStoreProtocol {
    
    // MARK: - Variables
    
    /// Activities (com a foto de cada uma) agrupadas por humor. É daqui que o gráfico tira a altura de cada barra.
    /// Não é `private(set)` porque a View também escreve nas propriedades que ligam a bindings (`$store.presentDetail`).
    var feelings: [Humor: [(activity: Activity, image: Image?)]] = [:]
    
    var presentDetail: Bool = false
    
    var selectedActivity: Activity? = nil
    
    /// Foto da atividade selecionada, já pronta para exibir. `nil` = sem foto.
    var selectedPhoto: Image? = nil
    
    // MARK: Câmera (a foto nova da atividade selecionada)
    
    var isCameraPresented: Bool = false
    
    var cameraFlashIcon: String = "bolt.slash"
    
    /// Mensagem do alerta de erro/permissão. `nil` = sem alerta.
    var errorMessage: String? = nil
    
    /// Liga o `.alert` à mensagem: abre quando há mensagem e, ao fechar, limpa.
    var isErrorPresented: Bool {
        get { errorMessage != nil }
        set { if !newValue { errorMessage = nil } }
    }
    
    // MARK: Compartilhar
    
    /// Imagem do story da atividade selecionada, já renderizada. `nil` = ainda não existe ou falhou.
    var storyImage: UIImage? = nil
    
    /// Controla o `.sheet(item:)` do share sheet. `nil` = fechado.
    var shareItem: ShareItem? = nil

    // MARK: - Carregamento

    /// Guarda os sentimentos já agrupados. Como a Store é `@Observable`,
    /// o gráfico que lê `feelings` se atualiza sozinho.
    func presentFeelingsLoaded(feelings: [Humor: [(activity: Activity, image: Image?)]]) {
        self.feelings = feelings
    }
    
    func presentActivityDetails(activity: Activity, photo: Image?) {
        self.selectedActivity = activity
        self.selectedPhoto = photo
        self.presentDetail = true
    }
    
    func returnToFeelings() {
        self.presentDetail = false
    }

    // MARK: - Câmera (tirar outra foto)

    func presentCamera(isPresented: Bool) {
        isCameraPresented = isPresented
    }
    
    func presentFlashIcon(_ icon: String) {
        cameraFlashIcon = icon
    }
    
    func presentError(_ message: String?) {
        errorMessage = message
    }
    
    /// Esconde ou volta com o sheet de detalhe, sem mexer na atividade selecionada.
    func presentDetailVisibility(isVisible: Bool) {
        presentDetail = isVisible
    }
    
    /// Troca a foto do detalhe e a do card da mesma atividade na lista.
    func presentPhoto(_ photo: Image?) {
        selectedPhoto = photo
        
        guard let selectedActivity else { return }
        for (humor, entries) in feelings {
            if let index = entries.firstIndex(where: { $0.activity === selectedActivity }) {
                feelings[humor]?[index].image = photo
            }
        }
    }

    // MARK: - Compartilhar

    func presentStoryImage(_ image: UIImage?) {
        storyImage = image
    }
    
    func presentShareSheet(_ item: ShareItem?) {
        shareItem = item
    }
}
