//
//  ChallengeDisplayView.swift
//  ChallengeFinal
//
//  Created by Paulo Henrique Costa Alves on 25/10/26.
//

import SwiftUI

/// Step `.challenge` antes de o usuário aceitar: mostra o desafio sorteado
/// num círculo e, depois de uma pequena animação, as opções de ação.
///
/// Não conhece o Interactor nem a Store: recebe o que mostrar e avisa os toques
/// por closures, que a `ActivityView` liga ao Interactor.
struct ChallengeDisplayView: View {

    // MARK: - Variables
    /// Categoria atual
    let currentCategory: ActivityCategory
    /// Título do desafio sorteado, exibido dentro do círculo.
    let challengeTitle: String
    /// Um novo desafio está sendo gerado por baixo dos panos (reroll).
    let isSearching: Bool
    /// "Arquivar desafio da lista".
    let archiveAction: () -> Void
    /// "aceitar": segue para a tela de desafio aceito.
    let acceptAction: () -> Void
    /// "Outra opção": pede um novo desafio.
    let refuseAction: () -> Void

    /// valor do offset da imagem
    var imageOffset: CGSize {
        switch currentCategory {
        case .physical:
            return CGSize(width: 0, height: -135)
        case .cognitive:
            return CGSize(width: 0, height: -120)
        case .sensorial:
            return CGSize(width: -30, height: -105)
        case .social:
            return CGSize(width: 0, height: -120)
        }
    }
    
    // MARK: - Estado interno (só de animação)
    /// O círculo sobe para abrir espaço para o diálogo embaixo.
    @State private var elevateCircle = false
    /// Mostra/esconde o diálogo e o botão de arquivar.
    @State private var showActions = false
    /// Popup de confirmação antes de arquivar o desafio.
    @State private var showArchiveConfirmation = false
    /// Popup de aviso depois que o desafio foi arquivado.
    @State private var showArchivedNotice = false

    var body: some View {
        VStack(alignment: .center) {
            // `Color.clear` ocupa a tela toda e define o tamanho do layout. A arte e as ações
            // ficam em `overlay`, que não altera esse tamanho: assim a arte, que é mais larga
            // que a tela em algumas categorias, não alarga o diálogo.
            Color.clear
                .overlay {
                    // O círculo com o desafio aparece primeiro, centralizado.
                    // Durante o reroll ele mostra uma mensagem de busca no lugar do título.
                    ChallengeCircle(category: currentCategory, text: challengeTitle, isOpen: true)
                        .offset(elevateCircle ? imageOffset : .zero)
                }
                // Depois do círculo, entram o diálogo e o botão.
                // O bloco fica ancorado embaixo, e o diálogo cobre a base da arte como no design.
                .overlay(alignment: .bottom) {
                    VStack(spacing: 17) {
                        ActionDialogComponent(title: "Gostaria de iniciar esse desafio?", firstOptionText: "Outra opção", secondOptionText: "aceitar", firstAction: refuseAction, secondAction: acceptAction)
                            .padding(.horizontal, 17)

                        CustomButtonComponent(title: "Arquivar desafio da lista", icon: "archivebox.fill", action: {
                            showArchiveConfirmation = true
                        })
                        .padding(.horizontal, 47)
                    }
                    .padding(.bottom, 184)
                    .opacity(showActions ? 1 : 0)
                    .offset(y: showActions ? 0 : 20)
                    // Invisível não pode receber toque.
                    .allowsHitTesting(showActions)
                }
                // A arte que passa da tela é cortada na borda, como no design.
                .clipped()
            // Esconde as ações enquanto procura e mostra de novo quando o desafio chega.
            // `id: isSearching` reinicia a task a cada mudança, cancelando o `sleep` anterior.
            .task(id: isSearching) {
                guard !isSearching else {
                    withAnimation(.easeOut(duration: 0.2)) { showActions = false }
                    return
                }
                // Na primeira vez espera o círculo subir; nos rerolls ele já está no lugar.
                let isFirstTime = !elevateCircle
                withAnimation(.easeOut(duration: 0.8)) {
                    elevateCircle = true
                }
                try? await Task.sleep(for: .seconds(isFirstTime ? 1.5 : 0.3))
                withAnimation(.easeOut(duration: 0.4)) {
                    showActions = true
                }
            }
        }
        .alert("Deseja arquivar o desafio do grupo?", isPresented: $showArchiveConfirmation) {
            Button("Cancelar", role: .cancel) {}
            Button("Excluir") {
                archiveAction()
                showArchivedNotice = true
            }
        } message: {
            Text("Depois de arquivado, você pode trazer de volta na tela de desafios.")
        }
        .alert("O desafio foi arquivado", isPresented: $showArchivedNotice) {
            Button("Ok") {}
        } message: {
            Text("Sorteie um novo desafio :)")
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity) // centraliza na tela toda
    }
}

// MARK: - Preview
#Preview("Mente") {
    ChallengeDisplayView(currentCategory: .cognitive, challengeTitle: "faça o seu cárdio sem abrir redes sociais", isSearching: false, archiveAction: {}, acceptAction: {}, refuseAction: {})
        .environment(DesignSystem.shared)
}

#Preview("Movimento") {
    ChallengeDisplayView(currentCategory: .physical, challengeTitle: "faça o seu cárdio sem abrir redes sociais", isSearching: false, archiveAction: {}, acceptAction: {}, refuseAction: {})
        .environment(DesignSystem.shared)
}

#Preview("Sentidos") {
    ChallengeDisplayView(currentCategory: .sensorial, challengeTitle: "faça o seu cárdio sem abrir redes sociais", isSearching: false, archiveAction: {}, acceptAction: {}, refuseAction: {})
        .environment(DesignSystem.shared)
}

#Preview("Conexão") {
    ChallengeDisplayView(currentCategory: .social, challengeTitle: "faça o seu cárdio sem abrir redes sociais", isSearching: false, archiveAction: {}, acceptAction: {}, refuseAction: {})
        .environment(DesignSystem.shared)
}
