//
//  Theme+StreakImage.swift
//  ChallengeFinal
//
//  Created by Raquel Souza on 21/11/26.
//

import SwiftUI

extension Theme {
    /// Ícone do streak já resolvido no modo claro, independente do modo do sistema.
    var streakImage: Image {
        let light = UITraitCollection(userInterfaceStyle: .dark)
        guard let lightImage = UIImage(named: streakIcon, in: nil, compatibleWith: light),
              let cgImage = lightImage.cgImage else {
            return Image(streakIcon)
        }
        // Recria a imagem sem o vínculo com o asset, pra ela não voltar pra variante dark.
        return Image(uiImage: UIImage(cgImage: cgImage, scale: lightImage.scale, orientation: lightImage.imageOrientation))
    }
}


/*
 caso em algum dos temas a variante do icon do Streak não ser o modo .dark, podemos implementar um switch, tipo assim:
 extension Theme {
     /// Modo (light/dark) em que o ícone do streak é exibido em cada tema.
     var streakIconMode: UIUserInterfaceStyle {
         switch self {
         case .sober: return .light
         case .pop: return .light
         case .bubblegum: return .light
         case .techNature: return .light
         }
     }
 
 ai ao invés de "(userInterfaceStyle: .dark)" a gente passa o streakIconMode.
 */
