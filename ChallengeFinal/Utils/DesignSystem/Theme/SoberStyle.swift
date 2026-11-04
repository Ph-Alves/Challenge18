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
        title1: .custom("Badoni 72", size: 36, relativeTo: .largeTitle),
        title2: .custom("Badoni 72", size: 32, relativeTo: .title),
        title3: .custom("Badoni 72", size: 24, relativeTo: .title3),
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
    
    let icons: IconsSet
    
    let humorWheel: HumorWheelStyle
    
}
