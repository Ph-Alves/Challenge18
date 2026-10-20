//
//  ActivitiesRouting.swift
//  ChallengeFinal
//
//  Created by Raquel Souza on 19/10/26.
//

import Foundation

protocol ActivityRouting: AnyObject {
    func didDraw()
    func didAcceptChallenge()
    func didCompleteChallenge()
    func didSelectMood()
    func didCapturePhoto()
    func didFinishChallenge()
}
