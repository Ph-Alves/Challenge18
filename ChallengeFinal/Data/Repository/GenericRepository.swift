//
//  GenericRepository.swift
//  ChallengeFinal
//
//  Created by Raquel Souza on 16/10/26.
//

import Foundation
import SwiftData


// MARK: -  Define o protocolo do Repository genérico
// GenericRepository<Entidade>(modelContext: modelContext)
protocol RepositoryProtocol<Model> {
    associatedtype Model: PersistentModel
    
    // MARK: - CRUD
    func getAll() throws -> [Model]
    func add(_ model: Model) throws
    func delete(_ model: Model) throws
    func cleanAll() throws
    func save() throws
}

struct GenericRepository<Model: PersistentModel>: RepositoryProtocol {
    // MARK: - Variaveis
    private let context: ModelContext
    
    // MARK: - Init
    init(context: ModelContext) {
        self.context = context
    }
    
    // MARK: - Adiciona uma nova entidade no banco
    func add(_ model: Model) throws {
        context.insert(model)
        try save()
    }
    
    // MARK: - Retorna as entidades do banco
    func getAll() throws -> [Model] {
        return try context.fetch(FetchDescriptor<Model>())
    }
    
    // MARK: - Deleta a um registro da entidade no banco
    func delete(_ model: Model) throws {
        context.delete(model)
        try save()
    }
    
    // MARK: - Limpa todos os registros da entidade salvas no banco
    func cleanAll() throws {
        try context.delete(model: Model.self)
        try save()
    }
    
    // MARK: - Salva as alterações
    func save() throws {
        if context.hasChanges {
            try context.save()
        }
    }
}
