//
//  ActivitiesRouting.swift
//  ChallengeFinal
//
//  Created by Raquel Souza on 19/10/26.
//

import Foundation

protocol ActivityRouting: AnyObject {
    var cached: ActivityView? { get set }
    var step: ActivityStep { get }
    
    func goToDraw()
    func goToChallenge()
    func goToInProgress()
    func goToMood()
    func goToPhoto()
    func goToSummary()
    /// Encerra o fluxo inteiro e devolve o usuário para a Home.
    func finishFlow()
}
