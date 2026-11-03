//
//  SoberStyle.swift
//  ChallengeFinal
//
//  Created by Rebeca Maria de Morais Guimães on 03/11/26.
//

import Foundation
internal import SwiftUI

struct SoberStyle: ThemeStyleProtocol {
    let typography = Typography(
        largeTitle: .custom("Bodoni 72", size: 32, relativeTo: .largeTitle),
        title: .custom("Badoni 72", size: 28, relativeTo: .title),
        subtitle: .custom("Badoni 72", size: 24, relativeTo: .title2),
        header: .custom("Special Gothic", size: 20, relativeTo: .title3),
        body: .custom("Special Gothic", size: 16, relativeTo: .body),
        caption: .custom("Special Gothic", size: 12, relativeTo: .caption))
    
    let colors: ColorPalette
    
    let icons: IconsSet
    
    let humorWheel: HumorWheelStyle
    
}
