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
    func presentWeek(days: [(date: Date, humor: Humor?)])
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
    
    // Converte cada Date na letra do dia ("D", "S", "T"...) em pt_BR e monta o WeekDay de cada um.
    // Regras de exibição:
    //  - dias anteriores a hoje: levam o humor recebido (nil = círculo vazio);
    //  - hoje: marcado com isToday (a View mostra o placeholderCheckIcon) e sem humor;
    //  - dias seguintes: sempre sem humor (círculo vazio).
    func presentWeek(days: [(date: Date, humor: Humor?)]) {
        let symbols = dateFormatter.veryShortWeekdaySymbols ?? []
        let calendar = Calendar.current
        let startOfToday = calendar.startOfDay(for: Date())
        
        let week = days.map { date, humor -> WeekDay in
            // weekday vai de 1 (domingo) a 7; o array de símbolos começa em 0.
            let weekdayIndex = calendar.component(.weekday, from: date) - 1
            // Compara pelo início do dia para ignorar a hora de `date`.
            let isPast = calendar.startOfDay(for: date) < startOfToday
            return WeekDay(label: symbols[weekdayIndex], humor: isPast ? humor : nil, isToday: calendar.isDateInToday(date))
        }
        
        store?.displayWeek(days: week)
    }
    
    // Só repassa: quem abre a tela é a Store, via Coordinator.
    func presentActivityFlow() {
        store?.displayActivityFlow()
    }
}
