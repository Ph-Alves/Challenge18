//
//  ChallengesInteractor.swift
//  ChallengeFinal
//
//  Created by Raquel Souza on 03/11/26.
//

import Foundation

protocol ChallengesInteractorProtocol: AnyObject {
    func loadChallenges()                             // tela apareceu: busca concluídos e arquivados
    func search(_ text: String)                       // digitou na busca
    func toggleCategory(_ category: ActivityCategory) // tocou num filtro (toca de novo para limpar)
    func openArchived()                               // botão de arquivados
    func closeArchived()                              // fechou o sheet (X ou arrastando)
    func restoreChallenge(_ activity: Activity)       // devolver o arquivado ao grupo
    func selectChallenge(_ activity: Activity)        // tocou num card: abre o resumo
    func dismissError()                               // fechou o alerta de erro
}
