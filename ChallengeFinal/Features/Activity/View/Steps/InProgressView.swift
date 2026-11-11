//
//  InProgressView.swift
//  ChallengeFinal
//
//  Created by Débora Cristina Silva Ferreira on 26/10/26.
//

import Foundation
import SwiftUI
import SwiftData

/// Tela do step `.inProgress`: mostra o desafio aceito e o cronômetro correndo.
///
/// Não conhece Store nem Interactor: recebe só textos e closures, e quem liga as
/// pontas é a `ActivityView` (lê da Store, avisa o Interactor). Por isso o
/// `#Preview` desta tela não precisa montar a arquitetura inteira.
struct InProgressView: View {

    /// Dados do desafio sorteado (vêm da Store pela `ActivityView`).
    let message: String
    let challengeSubTitle: String
    let challengeDescription: String
    let challengeIcon: String

    /// Tempo já formatado ("hh:mm:ss"). A View só exibe; quem calcula é o Interactor.
    let timeText: String

    /// Tocou em "encerrar": avisa o Interactor, que para o cronômetro e segue para o humor.
    let finishAction: () -> Void

    /// Confirmou o cancelamento no alerta: avisa o Interactor, que descarta o tempo e sai do fluxo.
    let cancelAction: () -> Void
    @Environment(DesignSystem.self) private var designSystem


    /// Controla o alerta de confirmação do cancelamento.
    /// É estado só de apresentação (nasce de um toque, sem regra de negócio),
    /// por isso fica na View e não passa por Presenter nem Store.
    @State private var isCancelAlertPresented = false

    var body: some View {
        VStack(alignment: .center) {
            ChallengeDescription(challengeIcon: challengeIcon, challengeTitle: message, challengeSubTitle: challengeSubTitle, challengeDescription: challengeDescription, spacingBetween: 36)

            // "cancelar" só abre o alerta de confirmação; "encerrar" termina a atividade.
            ActionDialogComponent(title: timeText, titleStyle: .timer,  secondOptionText: "encerrar", firstAction: { isCancelAlertPresented = true }, secondAction: finishAction, firstIcon: designSystem.style.icons.pauseIcon)
                .padding(. top, 86)
                .padding(.horizontal, 22)
            
            
        }
        // Confirmação antes de cancelar: só o botão destrutivo avisa o Interactor.
        // O cronômetro continua contando enquanto o alerta está aberto.
        .alert("cancelar a atividade?", isPresented: $isCancelAlertPresented) {
            Button("continuar", role: .cancel) { }
            Button("cancelar atividade", role: .destructive) { cancelAction() }
        } message: {
            Text("o tempo e o progresso desta atividade serão perdidos.")
        }
    }
}

#Preview {
    InProgressView(message: "faça o seu cárdio sem abrir redes sociais", challengeSubTitle: "menos distração, mais foco", challengeDescription: "sem redes sociais, seu cardio vira um momento para cuidar do corpo e desacelerar a mente.", challengeIcon: ActivityCategory.physical.cardIcon, timeText: "00:00:00", finishAction: { }, cancelAction: { }).environment(DesignSystem.shared)
}
