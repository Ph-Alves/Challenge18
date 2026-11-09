//
//  SoberStyle.swift
//  ChallengeFinal
//
//  Created by Rebeca Maria de Morais Guimães on 03/11/26.
//

import Foundation
import SwiftUI

struct SoberStyle: ThemeStyleProtocol {
    let typography = Typography(
        title1: .custom("Bodoni 72", size: 36, relativeTo: .largeTitle),
        title2: .custom("Bodoni 72", size: 32, relativeTo: .title),
        title3: .custom("Bodoni 72", size: 24, relativeTo: .title3),
        subtitle1:.custom("SpecialGothic-Bold", size: 22, relativeTo: .title2),
        subtitle2: .custom("SpecialGothic-SemiBold", size: 18, relativeTo: .title3),
        subtitle3: .custom("SpecialGothic-Bold", size: 14, relativeTo: .subheadline),
        text1: .custom("SpecialGothic-Regular", size: 22, relativeTo: .title2),
        text2: .custom("SpecialGothic-Regular", size: 16, relativeTo: .callout),
        text3: .custom("SpecialGothic-Regular", size: 12, relativeTo: .caption))
    
    let colors = ColorPalette(
        backgroundPrimary: .soberBackgroundPrimary,
        fillPrimary: .soberFillPrimary,
        fillPlaceholder: .soberFillPlaceholder,
        textPrimary: .soberTextPrimary,
        textSecondary: .soberTextSecondary,
        textInverse: .soberTextInverse,
        strokeDefault: .soberStrokeDefault,
        strokeSecondary: .soberStrokeSecondary,
        strokeMuted: .soberStrokeMuted,
        emotionOtimo: .soberEmotionOtimo,
        emotionAgradavel: .soberEmotionAgradavel,
        emotionNeutro: .soberEmotionNeutro,
        emotionDesagradavel: .soberEmotionDesagradavel,
        emotionPessimo: .soberEmotionPessimo,
        emotionStroke: .soberEmotionStroke,
        overlaySoft: .soberOverlaySoft,
        overlayStrong: .soberOverlayStrong)
    
    let icons = IconsSet(
        activityIcons: [
            .cognitive: (closed: "coffee",    open: "openCoffee"),
            .physical:  (closed: "eightBall", open: "openBall"),
            .sensorial: (closed: "coockie",   open: "openCookie"),
            .social:    (closed: "telephone", open: "openPhone")
        ],
        
        feelingIcons: [
            .veryUnpleasant: (base: "veryUnpleasantBase", humor: "veryUnpleasantHumor"),
            .unpleasant: (base: "unpleasantBase", humor: "unpleasantHumor"),
            .neutral: (base: "neutralBase", humor: "neutralHumor"),
            .pleasant: (base: "plesantBase", humor: "plesantHumor"),
            .veryPleasant: (base: "veryPleasantBase", humor: "veryPleasantHumor")
        ],
        placeholderCheckIcon: "placeholderCheckIcon",
        photoPlaceholder: "photoPlaceholder",
        archivedChallengeIcon: "archiveIcon",
        profilePlaceholder: "profilePlaceholder",
        camera: "camera",
        cameraIcon: "cameraIcon",
        nextIcon: "nextIcon",
        pauseIcon: "pauseIcon",
        tabBar: TabBarIcons(challenge: (base: "challengeTabIcon", fill: "challengeTabFill"), home: (base: "homeTabIcon", fill: "homeTabFill"), feelings: (base: "feelingsTabIcon", fill: "feelingsTabFill"), profile: (base: "profileTabIcon", fill: "profileTabFill")))
    
    let humorWheel = HumorWheelStyle(
        pointerAsset: "wheelArrow",
        backgroundAsset: "wheelBackground")
    
    let photoFilter: PhotoFilter? = PhotoFilter(
        saturation: 0,
        overlayColor: .black,
        overlayOpacity: 0.4)
    
}
