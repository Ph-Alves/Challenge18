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
    
    /// Data de criação já formatada. `nil` = não exibe.
    var createdAt: String? = nil
    
    @State private var openAlert: Bool = false
    
    var body: some View {
        NavigationStack {
            SummaryView(
                style: .display,
                category: selected.category,
                createdAt: createdAt,
                title: selected.name,
                description: selected.activityDescription,
                photo: photo,
                humor: selected.result?.humor,
                onFinish: retakeAction,
                onShare: shareAction
            )
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(role: .close, action: returnAction)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button("Apagar", systemImage: "trash", role: .destructive) {
                            
                            openAlert = true
                            
                        }
                        .tint(.red)
                    }label: {
                        
                        Image(systemName: "ellipsis")
                        
                    }
                }
            }
        }
        .alert("Realmente deseja apagar?", isPresented: $openAlert) {
            Button("Cancelar", role: .cancel) { openAlert = false }
            Button("Apagar", role: .destructive) {
                deleteAction(selected)
                returnAction()
            }
        } message: {
            Text("Ao apagar os dados, seus registros serão excluídos e o desafio voltará para a lista do grupo.")
        }
    }
}

#Preview {
    ActivityDetailView(returnAction: {}, deleteAction: {_ in}, retakeAction: {}, shareAction: {}, selected: Activity(category: .cognitive, result: nil, name: "", description: "", archived: false))
}
