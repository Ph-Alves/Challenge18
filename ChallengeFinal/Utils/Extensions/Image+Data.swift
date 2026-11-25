//
//  Image+Data.swift
//  ChallengeFinal
//
//  Created by Raquel Souza on 03/11/26.
//

import SwiftUI

extension Image {
    /// Foto salva (bytes) -> Image. `nil` = sem dado ou dado inválido.
    init?(data: Data?) {
        guard let data, let uiImage = UIImage(data: data) else { return nil }
        self.init(uiImage: uiImage)
    }
}
