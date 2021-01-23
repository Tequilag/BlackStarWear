//
//  Repository.swift
//  BSW
//
//  Created by Georgy Gorbenko on 09.01.2020.
//

import Foundation
import RealmSwift

protocol Repository: class, RepositoryNotification {
    
    typealias UpdatePolicy = Realm.UpdatePolicy
    
    init(_ configuration: RepositoryConfiguration) throws
    
    var configuration: RepositoryConfiguration { get }
    
    func fetch<T: Manageable>(_ model: T.Type, _ predicate: NSPredicate?, _ sorted: [Sorted]) throws -> [T]
    
    func save(_ models: [Manageable],
              update: UpdatePolicy,
              withoutTrigering tokens: [RepositoryNotificationController]) throws
    
    func deleteAndSave<T: Manageable>(deleteType: T.Type,
                                      predicate: NSPredicate?,
                                      save: [Manageable],
                                      update: UpdatePolicy,
                                      withoutTrigering tokens: [RepositoryNotificationController]) throws

    func deleteAll<T: Manageable>(deleteType: T.Type,
                                  predicate: NSPredicate?,
                                  withoutTrigering tokens: [RepositoryNotificationController]) throws
    
    func reset() throws
    
    func perform(updateAction closure: () throws -> Void) throws
}

extension Repository {
    
    func fetch<T: Manageable>(_ model: T.Type) throws -> [T] {
        
        return try fetch(model, nil, [])
    }
    
    func fetch<T: Manageable>(_ model: T.Type, _ sorted: [Sorted]) throws -> [T] {
        
        return try fetch(model, nil, sorted)
    }
    
    func fetch<T: Manageable>(_ model: T.Type, _ predicate: NSPredicate?) throws -> [T] {
        
        return try fetch(model, predicate, [])
    }
    
    func save(_ manageable: Manageable, update: UpdatePolicy) throws {
        
        try save([manageable], update: update, withoutTrigering: [])
    }
    
    func save(_ manageable: Manageable,
              update: UpdatePolicy,
              withoutTrigering tokens: [RepositoryNotificationController]) throws {
        
        try save([manageable], update: update, withoutTrigering: tokens)
    }
    
    func save(_ manageables: [Manageable], update: UpdatePolicy) throws {
        
        try save(manageables, update: update, withoutTrigering: [])
    }
    
    func deleteAll<T: Manageable>(deleteType: T.Type,
                                  predicate: NSPredicate?) throws {
        
        try deleteAll(deleteType: deleteType, predicate: predicate, withoutTrigering: [])
    }
    
    func deleteAll<T: Manageable>(deleteType: T.Type) throws {
        
        try deleteAll(deleteType: deleteType, predicate: nil, withoutTrigering: [])
    }
    
}

struct RepositoryAPI {
    
    static func newInstance(_ configuration: RepositoryConfiguration) throws -> Repository {
        
        return try RealmRepository(configuration)
    }
    
    internal struct BaseConfigurationForGlobalUser: RepositoryConfiguration {
    
        var repositoryType: RepositoryType { return .basic(username: "globalUser") }
        var isFileProtection: Bool { return true }
        var repositorySchemaVersion: UInt64 { return 0 }
        
        func repositoryDidBeginMigration(with migration: MigrationController) {
            
        }
    }
    
    static func globalInstance() throws -> Repository {
        
        return try RealmRepository(BaseConfigurationForGlobalUser())
    }
    
}
