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
    var time: TimeInterval = 0
    var humor: Humor = Humor.chill
    var activity: Activity?
    
    /// `photo` é opcional porque o usuário pode "continuar sem foto"
    init(photo: Data? = nil, time: TimeInterval, humor: Humor) {
        self.photo = photo
        self.time = time
        self.humor = humor
    }
}
