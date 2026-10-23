//
//  HomeCoordinatorView.swift
//  ChallengeFinal
//
//  Created by Raquel Souza on 19/10/26.
//

import SwiftUI

struct HomeView: View {

    // MARK: - Variables
    
    // Para executar
    let interactor: HomeInteractorProtocol
    // Para observar
    var store: HomeStore
    
    // MARK: - View
    var body: some View {
        VStack(spacing: 40) {
            // Parte superior de humor dos dias da semana
            WeeklyHumor(week: store.daysOfWeek)
                .padding(.bottom, 37)
            
            // Titutlo
            Text("Oi, desafie-se!")
                .font(.title.bold())

            // Circulo de desafio
            ChallengeCircle(text: "Eu te ajudo no que fazer <3")
            // Gesture para o swipe (esquerda/direita)
                .gesture(
                    DragGesture(minimumDistance: 20)
                    // Quando o swipe termina, eu verifico o valor
                        .onEnded { value in
                            // Se width > height, então e horizontal
                            let isHorizontalSwipe = abs(value.translation.width) > abs(value.translation.height)
                            guard isHorizontalSwipe else { return }

                            // pego o width
                            // Positivo: esquerda para direita
                            // Negativo: direita para esquerda
                            if value.translation.width < 0 {
                                interactor.nextCategory(current: store.currentCategory)
                            } else {
                                interactor.previousCategory(current: store.currentCategory)
                            }
                        }
                )
                .padding(.horizontal)
                .onTapGesture {
                    
                }

            
            // Texto da respectiva categoria
            CategoryText(category: store.currentCategory)
            
            Spacer()
        }
        .padding(.vertical)
        .onAppear() {
            // Prepara o array da semana atual (vai ser util quando tivemos o humor sendo registrado)
            interactor.getCurrentWeek()
        }
    }
}


// MARK: - Stub pro preview

// Usamos o stub por que controlamos melhor o que o preview vai mostrar e como vai mostrar
// No caso eu testo so a tela, sem interações.
private final class HomeInteractorStub: HomeInteractorProtocol {
    func getCurrentWeek() {}
    
    func nextCategory(current: ActivityCategory) {}
    
    func previousCategory(current: ActivityCategory) {}
}

// Aqui eu faço extension por que minha store ja tem minhas variáveis
// Eu so preparo ela com os valores que quero pro preview por que o interactor é vazio (logo acima)
extension HomeStore {
    static var preview: HomeStore {
        let state = HomeStore(coordinator: HomeCoordinator())
        
        state.daysOfWeek = ["D", "S", "T", "Q", "Q", "S", "S"]
        return state
    }
}

// MARK: - Preview
#Preview {
    HomeView(interactor: HomeInteractorStub(), store: .preview)
}
