//
//  TechNatureStyle.swift
//  ChallengeFinal
//
//  Created by Raquel Souza on 26/11/26.
//

import Foundation
import SwiftUI

struct TechNatureStyle: ThemeStyleProtocol {
    let typography = Typography(
        title1: .custom("Bodoni 72", size: 36, relativeTo: .largeTitle),
        title2: .custom("Bodoni 72", size: 32, relativeTo: .title),
        title3: .custom("Bodoni 72", size: 24, relativeTo: .title3),
        title4: .custom("Bodoni 72", size: 18, relativeTo: .title3),
        
        subtitle1:.custom("SpecialGothic-Bold", size: 22, relativeTo: .title2),
        subtitle2: .custom("SpecialGothic-SemiBold", size: 18, relativeTo: .title3),
        subtitle3: .custom("SpecialGothic-Bold", size: 14, relativeTo: .subheadline),
        
        text1: .custom("SpecialGothic-Regular", size: 22, relativeTo: .title2),
        text2: .custom("SpecialGothic-Regular", size: 16, relativeTo: .callout),
        text3: .custom("SpecialGothic-Regular", size: 12, relativeTo: .caption),
        text4: .custom("SpecialGothic-Bold", size: 36, relativeTo: .title))

    
    let colors = ColorPalette(
        backgroundPrimary: .techConstanceWhite,
        backgroundInverse: .techConstanceWhite,
        fillPrimary: .techConstanceGreen,
        fillPlaceholder: .techConstanceGreen,
        fillConstantDark: .techConstanceWhite,
        fillConstantLight: .techConstanceWhite,
        textPrimary: .techConstanceGreen,
        textSecondary: .techConstanceGreen,
        textInverse: .techConstanceWhite,
        strokeDefault: .techConstanceGreen,
        strokeSecondary: .techConstanceGreen,
        strokeMuted: .techConstanceGreen,
        emotionOtimo: .techVeryPleasant,
        emotionAgradavel: .techPleasant,
        emotionNeutro: .techNeutral,
        emotionDesagradavel: .techUnpleasant,
        emotionPessimo: .techVeryUnpleasant,
        emotionBGFill: .soberEmotionBGFill,
        strokeConstantDark: .techConstanceGreen,
        strokeConstantLight: .techConstanceGreen)
        
    
    let icons = IconsSet(
        //categorias
        activityIcons: [
            .cognitive: (homeCarousel: "techCognitiveCard", defaultClosed: "techCognitive", defaultOpen: "techCognitive", activityFlowCard: "techCognitiveWhite"),
            .physical: (homeCarousel: "techPyhsicalCard", defaultClosed: "techPhysical", defaultOpen: "techPhysical",  activityFlowCard: "techPhysicalWhite"),
            .sensorial: (homeCarousel: "techSensorialCard", defaultClosed: "techSensorial", defaultOpen: "techSensorial", activityFlowCard: "techSensorialWhite"),
            .social: (homeCarousel: "techSocialCard", defaultClosed: "techSocial", defaultOpen: "techSocial", activityFlowCard: "techSocialWhite"),
        ],
        
        feelingIcons: [
            .veryUnpleasant: (base: "techVeryUnpleasantHumor", humor: "techVeryUnpleasantHumor", card: "techVeryUnpleasantWhite", white: "techVeryUnpleasantWhite"),
            .unpleasant:     (base: "techVeryPleasantHumor",     humor: "techVeryPleasantHumor",     card: "techUnpleasantWhite",     white: "techUnpleasantWhite"),
            .neutral:        (base: "techNeutralHumor",        humor: "techNeutralHumor",        card: "techNeutralWhite",        white: "techNeutralWhite"),
            .pleasant:       (base: "techPleasantHumor",        humor: "techPleasantHumor",        card: "techPleasantWhite",       white: "techPleasantWhite"),
            .veryPleasant:   (base: "techVeryPleasantHumor",   humor: "techVeryPleasantHumor",   card: "techVeryPleasantWhite",   white: "techVeryPleasantWhite")
        ],
        
        placeholderCheckIcon: "techCheckIconPlaceholder",
        photoPlaceholder: "popPhotoPlaceholder",
        archivedChallengeIcon: "archiveIcon",
        archivedInvertedChallengeIcon: "archiveInvertedIcon",
        shareIcon: (base: "shareIcon", card: "shareIconCard"),
        retryIcon: (base: "retryIcon", card: "retryIconCard"),
        profilePlaceholder: "techProfilePlaceholder",
        takePicturePlaceholder: "techCameraPlaceholder",
        cameraIcon: "cameraIcon",
        nextIcon: "nextIcon",
        pauseIcon: "pauseIcon",
        challengeTab: TabBarIcons(
            challenge: (base: "techTabBar", fill: "techTabBar.fill"),
            home: (base: "house", fill: "house.fill"),
            feelings: (base: "chart.bar", fill: "chart.bar.fill"),
            profile: (base: "person", fill: "person.fill")),
        playIcon: "play.fill", handIcon: "handIcon")
    
    let humorWheel = HumorWheelStyle(
        pointerAsset: "wheelArrow",
        backgroundAsset: nil)
    
    let profile = ProfileStyle(
        headerBackground: "techHeaderBackground")
}
