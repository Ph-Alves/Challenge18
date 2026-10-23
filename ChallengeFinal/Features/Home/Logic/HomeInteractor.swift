//
//  HomeInteractor.swift
//  ChallengeFinal
//
//  Created by Raquel Souza on 16/10/26.
//

import Foundation

@MainActor
protocol HomeInteractorProtocol: AnyObject {
    func nextCategory(current: ActivityCategory)
    func previousCategory(current: ActivityCategory)
    func getCurrentWeek()
}

@MainActor
final class HomeInteractor: HomeInteractorProtocol {
    
    private let repository: GenericRepository<Activity>
    private let presenter: HomePresenterProtocol
    
    init(repository: GenericRepository<Activity>, presenter: HomePresenterProtocol) {
        self.repository = repository
        self.presenter = presenter
    }
    
    func getCurrentWeek() {
        // Pegamos o calendário para operações
        var calendar = Calendar.current
        // Setamos o primeiro dia da semana como 1 (domingo)
        calendar.firstWeekday = 1
        
        // Pegamos o dia atual
        let today = Date()
        
        // Aqui fazemos uma operação de intervalo, onde pegamos qual o intervalo do inicio da semana (domingo)
        // Por isso precisamos do calendar e do dia atual.
        // O date interval tem duas datas nele, Start e End, para que assim sabermos quando um intervalo inicia e quando termina, aqui queremos o inicio pois vamos gerar nossos dias em cima disso.
        guard let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: today)?.start else {
            return
        }
        
        // Aqui retornamos o resultado de um loop, fazendo o loop enquanto 0 for menor que 7 (7 dias)
        // Conseguimos fazer um "loop inline"
        // O que fazemos em cada um dos loops é pegar o offset (indice atual) e adicionar ele no date, ou seja, vamos pegar 7 dias a partir de domingo (startOfWeek)
        // O compactMap e um metodo que retorna um array de valores não nulos chamados a partir de uma closure
        let days = (0..<7).compactMap { offset in
            calendar.date(byAdding: .day, value: offset, to: startOfWeek)
        }
        
        presenter.presentWeek(days: days)
    }
    
    func nextCategory(current: ActivityCategory) {
        switch current {
        case .physical:
            presenter.presentCategory(.cognitive)
        case .cognitive:
            presenter.presentCategory(.sensorial)
        case .sensorial:
            presenter.presentCategory(.social)
        case .social:
            presenter.presentCategory(.physical)
        }
    }
    
    func previousCategory(current: ActivityCategory) {
        switch current {
        case .physical:
            presenter.presentCategory(.social)
        case .cognitive:
            presenter.presentCategory(.physical)
        case .sensorial:
            presenter.presentCategory(.cognitive)
        case .social:
            presenter.presentCategory(.sensorial)
        }
    }
}
