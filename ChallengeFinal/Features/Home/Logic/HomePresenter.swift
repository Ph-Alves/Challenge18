//
//  HomePresenter.swift
//  ChallengeFinal
//
//  Created by Raquel Souza on 16/10/26.
//

import Foundation

// MARK: - Protocol
@MainActor
protocol HomePresenterProtocol: AnyObject {
    func presentCategory(_ category: ActivityCategory)
    func presentWeek(days: [Date])
    func presentActivityFlow()
}

// MARK: - Class
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
    func presentCategory(_ category: ActivityCategory) {
        store?.displayCategory(category)
    }
    
    func presentWeek(days: [Date]) {
        let symbols = dateFormatter.veryShortWeekdaySymbols ?? []
        
        let weekLabels = days.map { date -> String in
            let weekdayIndex = Calendar.current.component(.weekday, from: date) - 1
            return symbols[weekdayIndex]
        }
        
        store?.displayWeek(days: weekLabels)
    }
    
    func presentActivityFlow() {
        store?.displayActivityFlow()
    }
}
