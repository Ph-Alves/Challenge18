//
//  HomePresenter.swift
//  ChallengeFinal
//
//  Created by Raquel Souza on 16/10/26.
//

import Foundation

// MARK: - Protocol
// O que o Interactor enxerga do Presenter (nos testes vira um spy).
@MainActor
protocol HomePresenterProtocol: AnyObject {
    func presentCategory(_ category: ActivityCategory)
    func presentWeek(days: [Date])
    func presentActivityFlow()
}

// MARK: - Class
// "Tradutor" da Home: recebe dados crus do Interactor (Date, enum),
// transforma no formato da tela (letras dos dias) e entrega para a Store.
// Não tem regra de negócio e não conhece View nem Interactor.
@MainActor
final class HomePresenter: HomePresenterProtocol {
    // MARK: - Variables
    
    // Store (tem que ser referência fraca)
    weak var store: HomeStoreProtocol?
    
    // Formatador de data (para caso precisemos de valores de data futuros)
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "pt_BR")
        return formatter
    }()
    
    // MARK: - Init
    init(store: HomeStoreProtocol) {
        self.store = store
    }
    
    // MARK: - Functions
    // A categoria não precisa de formatação, só é repassada.
    func presentCategory(_ category: ActivityCategory) {
        store?.displayCategory(category)
    }
    
    // Converte cada Date na letra do dia ("D", "S", "T"...) em pt_BR.
    func presentWeek(days: [Date]) {
        let symbols = dateFormatter.veryShortWeekdaySymbols ?? []
        
        let weekLabels = days.map { date -> String in
            // weekday vai de 1 (domingo) a 7; o array de símbolos começa em 0.
            let weekdayIndex = Calendar.current.component(.weekday, from: date) - 1
            return symbols[weekdayIndex]
        }
        
        store?.displayWeek(days: weekLabels)
    }
    
    // Só repassa: quem abre a tela é a Store, via Coordinator.
    func presentActivityFlow() {
        store?.displayActivityFlow()
    }
}
