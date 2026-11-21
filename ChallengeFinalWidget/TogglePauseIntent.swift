import AppIntents
import Foundation

extension Notification.Name {
    /// Postada pelo botão da Live Activity; o Interactor observa e pausa ou retoma.
    nonisolated static let toggleTimerPause = Notification.Name("toggleTimerPause")
}


struct TogglePauseIntent: LiveActivityIntent {
    static let title: LocalizedStringResource = "Pausar ou retomar"
    
    func perform() async throws -> some IntentResult {
            NotificationCenter.default.post(name: .toggleTimerPause, object: nil)
        return .result()
    }
}
