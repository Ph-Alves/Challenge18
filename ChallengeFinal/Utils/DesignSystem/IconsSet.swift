//
//  IconsSet.swift
//  ChallengeFinal
//
//  Created by Rebeca Maria de Morais Guimães on 03/11/26.
//

import Foundation

struct IconsSet {
    let activityIcons: [ActivityCategory: (homeCarousel: String, defaultClosed: String, defaultOpen: String, activityFlowCard: String)]
    let feelingIcons: [Humor: (base: String, humor: String, card: String, white: String)]
    let placeholderCheckIcon: String // foi
    let photoPlaceholder: String //foi
    let archivedChallengeIcon: String  //foi//foi
    let archivedInvertedChallengeIcon: String
    let shareIcon: (base: String, card: String)
    let retryIcon: (base: String, card: String)
    let profilePlaceholder: String // foi
    let takePicturePlaceholder: String // foi
    let cameraIcon: String // foi
    let nextIcon: String // foi
    let pauseIcon: String //foi
    let tabBar: TabBarIcons
    let playIcon: String
}

