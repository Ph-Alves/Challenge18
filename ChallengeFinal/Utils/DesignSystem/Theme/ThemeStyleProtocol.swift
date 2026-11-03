//
//  ThemeStyleProtocol.swift
//  ChallengeFinal
//
//  Created by Rebeca Maria de Morais Guimães on 03/11/26.
//

import Foundation

protocol ThemeStyleProtocol {
    var typography: Typography { get }
    var colors: ColorPalette { get }
    var icons: IconsSet { get }
    var humorWheel: HumorWheelStyle { get }
    var photoFilter: PhotoFilter? { get }
}

extension ThemeStyleProtocol {
    var photoFilter: PhotoFilter? { nil }
}
