//
//  HomePresenter.swift
//  ChallengeFinal
//
//  Created by Raquel Souza on 16/10/26.
//

import Foundation

@MainActor
protocol HomePresenterProtocol: AnyObject {
    func presentCategory(_ category: ActivityCategory)
    func presentWeek(days: [Date])
}

@MainActor
final class HomePresenter: HomePresenterProtocol {
    weak var store: HomeStoreProtocol?
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "pt_BR")
        return formatter
    }()
    
    init(store: HomeStoreProtocol) {
        self.store = store
    }
    
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
}
