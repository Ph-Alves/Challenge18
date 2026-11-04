//
//  ActivityDetailView.swift
//  ChallengeFinal
//
//  Created by Paulo Henrique Costa Alves on 03/11/26.
//

import SwiftUI

struct ActivityDetailView: View {
    
    let returnAction: () -> Void
    let deleteAction: (Activity) -> Void
    let retakeAction: () -> Void
    let shareAction: () -> Void
    let selected: Activity
    
    /// Foto já pronta para exibir. `nil` = card vazio.
    var photo: Image? = nil
    
    @State private var openAlert: Bool = false
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "pt_BR")
        formatter.dateFormat = "dd 'de' MMMM 'de' YYYY"
        return formatter
    }
    
    var body: some View {
        VStack {
            HStack {
                Button {
                    returnAction()
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 17))
                }
                .buttonStyle(.plain)
                .padding(10)
                .background(.gray)
                .clipShape(.circle)
                
                
                Spacer()
                Text(dateFormatter.string(from: selected.createdAt))
                Spacer()
                
                Button {
                    openAlert = true
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 17))
                }
                .buttonStyle(.plain)
                .padding()
                .background(.gray)
                .clipShape(.circle)
            }
            .padding()
            
            SummaryView(
                style: .display,
                title: selected.name,
                description: selected.activityDescription,
                photo: photo,
                humor: selected.result?.humor,
                onFinish: retakeAction,
                onShare: shareAction)
        }
        .alert("Realmente deseja apagar?", isPresented: $openAlert, actions: {
            Button("Cancelar", role: .cancel) { openAlert = false
            }
            Button("Arquivar", role: .destructive) {
                deleteAction(selected)
                returnAction()
            }
        }, message: {
            Text("Ao apagar os dados, seus registros serão excluídos e o desafio voltará para a lista do grupo.")
        })
    }
}

#Preview {
    ActivityDetailView(returnAction: {}, deleteAction: {_ in}, retakeAction: {}, shareAction: {}, selected: Activity(category: .cognitive, result: nil, name: "", description: "", archived: false))
}
