//
//  Results.swift
//  ChallengeFinal
//
//  Created by Raquel Souza on 16/10/26.
//
import SwiftData
import Foundation

// MARK: - Resultado da atividade realizada pelo usuario
@Model
final class ActivityResult {
    var resultID: UUID = UUID()
    @Attribute(.externalStorage) var photo: Data?
    var achievementTitle: String
    var achievementDescription: String
    var time: TimeInterval = 0
    var humor: Humor?
    var activity: Activity?
    
    /// `photo` é opcional porque o usuário pode "continuar sem foto"
    /// A conquista é gerada em paralelo aos steps de humor e foto, por isso começa vazia.
    /// `humor` é opcional porque o resultado pode existir antes de o humor ser escolhido.
    init(photo: Data? = nil, achievementTitle: String = "", achievementDescription: String = "", time: TimeInterval, humor: Humor? = nil) {
        self.photo = photo
        self.achievementTitle = achievementTitle
        self.achievementDescription = achievementDescription
        self.time = time
        self.humor = humor
    }
}
