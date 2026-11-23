//
//  ProfileNameField.swift
//  ChallengeFinal
//
//  Created by Raquel Souza on 17/11/26.
//

import SwiftUI

struct ProfileNameField: View {
    
    //DS atalhos
    @Environment(DesignSystem.self) private var designSystem
    private var colors: ColorPalette { designSystem.style.colors }
    
    let name: String
    let isEditing: Bool
    @Binding var draftName: String
    var isFocused: FocusState<Bool>.Binding
    let onSubmit: () -> Void


    var body: some View {
        ZStack(alignment: .trailing) {
            Group {
                if isEditing {
                    TextField("", text: $draftName, prompt: Text("nome"))
                        .focused(isFocused)
                        .submitLabel(.done)
                        .onSubmit(onSubmit)
                        .foregroundStyle(colors.fillConstantLight)
//                        .tint(.pink)
                } else {
                    Text(name)
                        .lineLimit(1)
                        .foregroundStyle(colors.fillConstantLight)
                }
            }
            .font(designSystem.style.typography.subtitle1)
            .multilineTextAlignment(.center)
            .frame(width: 215, height: 29)
            .frame(maxWidth: .infinity)

            if isEditing {
                Image(systemName: "pencil")
                    .foregroundStyle(colors.fillConstantLight)
                    .padding(.trailing, 16)
            }
        }
        .frame(maxWidth: 332)
        .frame(height: 40)
        .background(colors.fillConstantDark)
        .clipShape(RoundedRectangle(cornerRadius: 63))
        .overlay(RoundedRectangle(cornerRadius: 63).stroke(colors.fillConstantLight, lineWidth: 1))
    }
}

#Preview("Visualizando") {
    @Previewable @State var draftName = "Raquel"
    @Previewable @FocusState var isFocused: Bool

    ZStack {
        Color.pink.ignoresSafeArea()   

        ProfileNameField(
            name: "Raquel",
            isEditing: false,
            draftName: $draftName,
            isFocused: $isFocused,
            onSubmit: {}
        )
        .padding()
    }
    .environment(DesignSystem.shared)
}

#Preview("Editando") {
    @Previewable @State var draftName = "Raquel"
    @Previewable @FocusState var isFocused: Bool

    ZStack {
        Color.pink.ignoresSafeArea()
        
        ProfileNameField(
            name: "Raquel",
            isEditing: true,
            draftName: $draftName,
            isFocused: $isFocused,
            onSubmit: { isFocused = false }
        )
        .padding()
    }
    .environment(DesignSystem.shared)
}

