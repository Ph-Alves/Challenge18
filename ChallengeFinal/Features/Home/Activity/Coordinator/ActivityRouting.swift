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
    
    func didReturn()
    func didDraw()
    func didAcceptChallenge()
    func didCompleteChallenge()
    func didSelectMood()
    func didCapturePhoto()
    func didFinishChallenge()
}
