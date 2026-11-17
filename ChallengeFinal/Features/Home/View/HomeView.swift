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

    // Estado da animação do carrossel no swipe:
    // 0 = parado, -1 = deslizando para a próxima categoria, +1 = para a anterior
    @State private var slide: CGFloat = 0
    @State private var isAnimatingSwipe = false

    // MARK: - Animation

    // Troca a categoria: todos os círculos andam um slot para o lado do swipe
    // (o vizinho cresce e toma o centro, o atual encolhe e vai para a lateral).
    private func changeCategory(towardsNext: Bool) {
        guard !isAnimatingSwipe else { return }
        isAnimatingSwipe = true
        
        // Swipe para esquerda (próxima): tudo desliza para a esquerda (slide = -1)
        withAnimation(.easeInOut(duration: 0.3)) {
            slide = towardsNext ? -1 : 1
        }

        Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(300))
            if towardsNext {
                interactor.nextCategory(current: store.currentCategory)
            } else {
                interactor.previousCategory(current: store.currentCategory)
            }
            // Com a categoria nova, os slots já mostram as imagens certas:
            // volta para 0 sem animar, que o resultado visual é o mesmo.
            // Toda mudança de estado carrega uma transaction, que define como a mudança deve ser animada.
            var transaction = Transaction(animation: nil)
            transaction.disablesAnimations = true
            withTransaction(transaction) {
                slide = 0
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
                // Carrossel: categoria atual no centro e vizinhas (anterior/próxima) nas laterais
                CategoryCarousel(current: store.currentCategory, slide: slide) {
                    interactor.startActivity()
                }
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
        
        state.daysOfWeek = ["D", "S", "T", "Q", "Q", "S", "S"].map { WeekDay(label: $0, humor: nil) }
        return state
    }
}

// MARK: - Preview
#Preview {
    HomeView(interactor: HomeInteractorStub(), store: .preview)
        .environment(DesignSystem.shared)
}
