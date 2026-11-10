//
//  HomeCoordinatorView.swift
//  ChallengeFinal
//
//  Created by Raquel Souza on 19/10/26.
//

import SwiftUI

// Tela inicial: mostra a semana, o círculo de desafio e a categoria atual.
// Swipe horizontal troca a categoria; toque no círculo inicia a Activity.
// A View só LÊ a Store e só CHAMA o Interactor, sem regra própria.
struct HomeView: View {

    // MARK: - Variables
    
    @Environment(DesignSystem.self) private var designSystem
    
    // Para executar
    let interactor: HomeInteractorProtocol
    // Para observar
    var store: HomeStore

    // Estado da animação do círculo no swipe
    @State private var imageOffset: CGFloat = 0
    @State private var imageOpacity: Double = 1
    @State private var isAnimatingSwipe = false

    // MARK: - Animation

    // Troca a categoria: a imagem atual sai para o lado do swipe
    // e a nova entra vindo do lado oposto.
    private func changeCategory(towardsNext: Bool) {
        guard !isAnimatingSwipe else { return }
        isAnimatingSwipe = true
        // Swipe para esquerda (próxima): sai pela esquerda, entra pela direita
        let distance: CGFloat = towardsNext ? -200 : 200

        withAnimation(.easeIn(duration: 0.15)) {
            imageOffset = distance
            imageOpacity = 0
        }

        Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(150))
            if towardsNext {
                interactor.nextCategory(current: store.currentCategory)
            } else {
                interactor.previousCategory(current: store.currentCategory)
            }
            // Reposiciona do lado oposto sem animar
            // Toda mudança de estado carrega uma transaction, que define como a mudança deve ser animada.
            var transaction = Transaction(animation: nil)
            transaction.disablesAnimations = true
            withTransaction(transaction) {
                imageOffset = -distance
            }
            withAnimation(.spring(duration: 0.3)) {
                imageOffset = 0
                imageOpacity = 1
            }
            isAnimatingSwipe = false
        }
    }

    // MARK: - View
    var body: some View {
        VStack(spacing: 10) {
            // Parte superior de humor dos dias da semana
            WeeklyHumor(week: store.daysOfWeek)
                .padding(.bottom, 36)
            
            VStack {
                // Titutlo
                Text("oi, desafie-se!")
                    .font(designSystem.currentTheme.style.typography.title1)
                // Subtitulo
                Text("aperte e encontre o desafio \nperfeito para você")
                    .font(designSystem.currentTheme.style.typography.text2)
                    .multilineTextAlignment(.center)
            }
            
            VStack {
                // Circulo de desafio
                ChallengeCircle(category: store.currentCategory, text: nil, isOpen: false)
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
                                changeCategory(towardsNext: value.translation.width < 0)
                            }
                    )
                    .offset(x: imageOffset)
                    .opacity(imageOpacity)
                    .onTapGesture {
                        interactor.startActivity()
                    }
                
                
                // Texto da respectiva categoria
                CategoryText(category: store.currentCategory)
                    .font(designSystem.currentTheme.style.typography.title3)
            }
            
            Spacer()
            
            // Indicador de categoria: a barra da categoria atual fica maior
            HStack(spacing: 10) {
                ForEach(ActivityCategory.allCases, id: \.self) { category in
                    let isSelected = category == store.currentCategory
                    Capsule()
                        .frame(width: isSelected ? 5 : 2, height: isSelected ? 20 : 14)
                }
            }
            .frame(height: 20)
            .animation(.easeInOut(duration: 0.2), value: store.currentCategory)
            
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
    func startActivity() {}
    
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
        .environment(DesignSystem.shared)
}
