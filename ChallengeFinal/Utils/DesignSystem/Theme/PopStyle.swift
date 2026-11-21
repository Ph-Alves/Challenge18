//
//  PopStyle.swift
//  ChallengeFinal
//
//  Created by Raquel Souza on 21/11/26.
//

import Foundation
import SwiftUI

struct PopStyle: ThemeStyleProtocol {

    // MARK: - Fontes
    // TODO: trocar fontes
    private static let titleFont         = "Bodoni 72"
    private static let subtitleBold      = "SpecialGothic-Bold"
    private static let subtitleSemiBold  = "SpecialGothic-SemiBold"
    private static let textRegular       = "SpecialGothic-Regular"
    private static let textBold          = "SpecialGothic-Bold"

    let typography = Typography(
        title1: .custom(titleFont, size: 36, relativeTo: .largeTitle),
        title2: .custom(titleFont, size: 32, relativeTo: .title),
        title3: .custom(titleFont, size: 24, relativeTo: .title3),
        title4: .custom(titleFont, size: 18, relativeTo: .title3),

        subtitle1: .custom(subtitleBold,     size: 22, relativeTo: .title2),
        subtitle2: .custom(subtitleSemiBold, size: 18, relativeTo: .title3),
        subtitle3: .custom(subtitleBold,     size: 14, relativeTo: .subheadline),

        text1: .custom(textRegular, size: 22, relativeTo: .title2),
        text2: .custom(textRegular, size: 16, relativeTo: .callout),
        text3: .custom(textRegular, size: 12, relativeTo: .caption),
        text4: .custom(textBold,    size: 36, relativeTo: .title))

    // MARK: - Cores
    let colors = ColorPalette(
        
        //Base Colors
        backgroundPrimary: .popConstantDark,
        backgroundInverse: .popConstantDark,
        fillPrimary: .popConstantLight,
        fillPlaceholder: .popConstantLight,
        fillConstantDark: .popConstantDark,
        fillConstantLight: .popConstantGray,
        textPrimary: .popConstantLight,
        textSecondary: .popConstantGray,
        textInverse: .popConstantDark,
        strokeDefault: .popConstantLight,
        strokeSecondary: .popConstantGray,
        strokeMuted: .popConstantDark,
        
        // Emoções
        emotionOtimo: .popVeryPleasant,
        emotionAgradavel: .popPleasant,
        emotionNeutro: .popNeutral,
        emotionDesagradavel: .popUnpleasant,
        emotionPessimo: .popVeryUnpleasant,
//        emotionStroke: .popConstantDark,
        
        //to review
        overlaySoft: .soberOverlaySoft,           // TODO
        overlayStrong: .soberOverlayStrong,       // TODO
        emotionBGFill: .soberEmotionBGFill,       // TODO
        strokeConstantDark: .popConstantDark,
        strokeConstantLight: .popConstantGray)

    // MARK: - Ícones
    let icons = IconsSet(

        //categorias
        activityIcons: [
            .cognitive: (homeCarousel: "diceCard", defaultClosed: "dice", defaultOpen: "openDice", activityFlowCard: "dice"),
            .physical: (homeCarousel: "coneCard", defaultClosed: "cone", defaultOpen: "openCone", activityFlowCard: "cone"),
            .sensorial: (homeCarousel: "lampCard", defaultClosed: "lamp", defaultOpen: "openLamp", activityFlowCard: "lamp"),
            .social: (homeCarousel: "tomatoCard", defaultClosed: "tomato", defaultOpen: "openTomato", activityFlowCard: "tomato"),
        ],

        //sentimentos
        feelingIcons: [
            .veryUnpleasant: (base: "popVeryUnpleasantHumor", humor: "popVeryUnpleasantHumor", card: "popVeryUnpleasantHumor", white: "popVeryUnpleasantHumor"),
            .unpleasant:     (base: "popUnpleasantHumor",     humor: "popUnpleasantHumor",     card: "popUnpleasantHumor",     white: "popUnpleasantHumor"),
            .neutral:        (base: "popNeutralHumor",        humor: "popNeutralHumor",        card: "popNeutralHumor",        white: "popNeutralHumor"),
            .pleasant:       (base: "popPleasantHumor",        humor: "popPleasantHumor",       card: "popPleasantHumor",       white: "popPleasantHumor"),
            .veryPleasant:   (base: "popVeryPleasantHumor",   humor: "popVeryPleasantHumor",   card: "popVeryPleasantHumor",   white: "popVeryPleasantHumor")
        ],
        
        //placeholders
        placeholderCheckIcon: "popCheckIconPlaceholder",
        photoPlaceholder: "popPhotoPlaceholder",
        
        archivedChallengeIcon: "archiveIcon",
        archivedInvertedChallengeIcon: "archiveInvertedIcon",
        shareIcon: (base: "shareIcon", card: "shareIconCard"),
        retryIcon: (base: "retryIcon", card: "retryIconCard"),
        profilePlaceholder: "popProfilePlaceholder",
        takePicturePlaceholder: "popPhotoPlaceholder",
        cameraIcon: "cameraIcon",
        nextIcon: "nextIcon",
        pauseIcon: "pauseIcon",
        
        //tabBar
        tabBar: TabBarIcons(
            challenge: (base: "challengeTabIcon", fill: "challengeTabFill"),
            home:      (base: "house",            fill: "house.fill"),
            feelings:  (base: "feelingsTabIcon",  fill: "feelingsTabFill"),
            profile:   (base: "profileTabIcon",   fill: "profileTabFill")),
        
        playIcon: "play.fill")

    // MARK: - Roda de humor
    let humorWheel = HumorWheelStyle(
        pointerAsset: "wheelArrow",
        backgroundAsset: nil)

    // MARK: - Perfil
    let profile = ProfileStyle(
        headerBackground: "popHeaderBackground")
}
