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
    /// Título do desafio sorteado, exibido dentro do círculo.
    let challengeTitle: String
    /// Um novo desafio está sendo gerado por baixo dos panos (reroll).
    let isSearching: Bool
    /// Seta de voltar: encerra o fluxo e devolve o usuário à Home.
    let returnAction: () -> Void
    /// "Arquivar desafio da lista".
    let archiveAction: () -> Void
    /// "aceitar": segue para a tela de desafio aceito.
    let acceptAction: () -> Void
    /// "Outra opção": pede um novo desafio.
    let refuseAction: () -> Void

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
            ZStack {
                // O círculo com o desafio aparece primeiro, centralizado.
                // Durante o reroll ele mostra uma mensagem de busca no lugar do título.
                ChallengeCircle(text: isSearching ? "Procurando um novo desafio..." : challengeTitle, size: .big)
                    .offset(y: elevateCircle ? -120 : 0)

                // Depois do círculo, entram o diálogo e o botão.
                // O `padding(.top, 250)` posiciona o bloco abaixo do círculo já elevado.
                VStack(spacing: 24) {
                    ActionDialogComponent(title: "Gostaria de iniciar esse desafio?", firstOptionText: "Outra opção", secondOptionText: "aceitar", firstAction: refuseAction, secondAction: acceptAction)
                        .padding(.horizontal)
                    
                    CustomButtonComponent(title: "Arquivar desafio da lista", icon: "archivebox.fill", action: {
                        showArchiveConfirmation = true
                    })
                        .padding(.horizontal, 70)
                }
                .padding(.top, 250)
                .opacity(showActions ? 1 : 0)
                .offset(y: showActions ? 0 : 20)
                // Invisível não pode receber toque.
                .allowsHitTesting(showActions)
            }
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
        .overlay(alignment: .topLeading) {
            BackButton(action: returnAction)
                .padding(.horizontal)
        }
    }
}

// MARK: - Preview
#Preview {
    ChallengeDisplayView(challengeTitle: "teste", isSearching: false, returnAction: {}, archiveAction: {}, acceptAction: {}, refuseAction: {})
}
