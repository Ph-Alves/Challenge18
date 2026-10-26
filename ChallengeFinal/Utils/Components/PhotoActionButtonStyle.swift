//
//  PhotoActionButtonStyle.swift
//  ChallengeFinal
//
//  Created by Raquel Souza on 26/10/26.
//


//
//  PhotoActionButtonStyle.swift
//  ChallengeFinal
//
//  Created by Raquel Souza on 26/10/26.
//

import SwiftUI

/// Botões cinza de largura total, com ícone + texto em negrito e sombra suave
/// (ex.: "tire uma foto!" e "importar da galeria").
///
/// Como ocupam toda a largura disponível, botões na mesma coluna
/// ficam sempre com a mesma largura.
///
/// Funciona com `Button` e com `PhotosPicker`:
/// ```swift
/// Button(action: ...) { Label("tire uma foto!", systemImage: "camera.fill") }
///     .buttonStyle(PhotoActionButtonStyle())
/// ```
///
/// Dica: quando o `DesignSystem.swift` tiver cores e fontes, troque os valores fixos daqui.
struct PhotoActionButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 15, weight: .semibold))
            .foregroundStyle(.black)
            .frame(maxWidth: .infinity)
            .frame(height: 36)
            .background(Color(white: 0.88), in: .rect(cornerRadius: 12))
            .shadow(color: .black.opacity(0.15), radius: 4, y: 3)
            // Leve feedback ao pressionar.
            .opacity(configuration.isPressed ? 0.7 : 1)
    }
}