//
//  ActivityInteractor+Timer.swift
//  ChallengeFinal
//
//  Created by Débora Cristina Silva Ferreira on 26/10/26.
//

import Foundation

extension ActivityInteractor {
    func startTimer( ) {
        timerTask?.cancel()
        timerStartDate = Date()
        timerTask = Task { [weak self] in
            guard let ticks = self?.timer.ticks() else { return }
            
            for await _ in ticks {
                guard let self else { return }
                presenter.presentTime(currentElapsed())
            }
        }
    }
    
    func stopTimer() {
        timerTask?.cancel()
        timerElapsed = currentElapsed()
        timerStartDate = nil
    }
    
    func cancelTimer() {
        timerTask?.cancel()
        timerTask = nil
        timerStartDate = nil
        timerElapsed = 0
        presenter.presentTime(0)
    }
    
    func currentElapsed() -> TimeInterval {
        guard let start = timerStartDate else { return 0}
        return Date().timeIntervalSince(start)
    }
}
