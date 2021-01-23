//
//  RealmRepository.swift
//  BSW
//
//  Created by Georgy Gorbenko on 09.01.2020.
//

import Foundation
import RealmSwift

private func baseRepositoryConfiguration(for user: String,
                                         _ schemaVersion: UInt64,
                                         _ isFileProtection: Bool) -> Realm.Configuration {
    
    var configuration = Realm.Configuration(schemaVersion: schemaVersion)
    
    guard let path = configuration.fileURL?.deletingLastPathComponent()
        .appendingPathComponent("\(user).realm") else { return configuration }
    configuration.fileURL = path
    
    if isFileProtection {
        
        guard let folderPath = configuration.fileURL?.deletingLastPathComponent().path else { return configuration }
        do {
            
            try FileManager.default.setAttributes([FileAttributeKey.protectionKey: FileProtectionType.none],
                                                  ofItemAtPath: folderPath)
        }
        catch {
            
            return configuration
        }
    }
    return configuration
}

private func encryptionRepositoryConfiguration(for user: String,
                                               _ encryptionKey: Data,
                                               _ schemaVersion: UInt64,
                                               _ isFileProtection: Bool) -> Realm.Configuration {
    
    var configuration = Realm.Configuration(encryptionKey: encryptionKey, schemaVersion: schemaVersion)
    configuration.fileURL = configuration.fileURL!.deletingLastPathComponent()
        .appendingPathComponent("\(user)Encryption.realm")
    
    if isFileProtection {
        
        guard let folderPath = configuration.fileURL?.deletingLastPathComponent().path else { return configuration }
        do {
            
            try FileManager.default.setAttributes([FileAttributeKey.protectionKey: FileProtectionType.none],
                                                  ofItemAtPath: folderPath)
        }
        catch {
            
            return configuration
        }
    }
    return configuration
}

internal class RealmRepository: Repository {
    
    private let realm: Realm?
    let configuration: RepositoryConfiguration
    
    required init(_ configuration: RepositoryConfiguration) throws {
        
        var realmConfiguration: Realm.Configuration
        switch configuration.repositoryType {
            
        case .basic(let username):
            realmConfiguration = baseRepositoryConfiguration(for: username,
                                                             configuration.repositorySchemaVersion,
                                                             configuration.isFileProtection)
        case .basicEncryption(let username, let encryptionKey):
            realmConfiguration = encryptionRepositoryConfiguration(for: username,
                                                                   encryptionKey,
                                                                   configuration.repositorySchemaVersion,
                                                                   configuration.isFileProtection)
        case .inMemory(let identifier):
            realmConfiguration = Realm.Configuration(inMemoryIdentifier: identifier)
        }
        
        realmConfiguration.migrationBlock = { migration, oldSchemaVersion in
            
            let migrationController = MigrationContextProducer(configuration.repositorySchemaVersion,
                                                               oldSchemaVersion,
                                                               migration)
            configuration.repositoryDidBeginMigration(with: migrationController)
        }
        
        self.configuration = configuration
        do {
            
            self.realm = try Realm(configuration: realmConfiguration)
            
        } catch {
            
            throw RepositoryError.initialization
        }
    }
    
    func fetch<T: Manageable>(_ model: T.Type, _ predicate: NSPredicate?, _ sorted: [Sorted]) throws -> [T] {
        
        let realm = try safeRealm()
        return realm.objects(model)
            .filter(predicate)
            .sort(sorted)
            .map { $0 }
    }
    
    func save(_ models: [Manageable],
              update: UpdatePolicy,
              withoutTrigering tokens: [RepositoryNotificationController]) throws {
        
        let realm = try safeRealm()
        try safePerform(withoutTriggering: tokens, { realm.add(models, update: update) })
    }
    
    func deleteAndSave<T: Manageable>(deleteType: T.Type,
                                      predicate: NSPredicate?,
                                      save: [Manageable],
                                      update: UpdatePolicy,
                                      withoutTrigering tokens: [RepositoryNotificationController]) throws {
        
        let realm = try safeRealm()
        let delete = try fetch(deleteType, predicate, [])
        try safePerform(withoutTriggering: tokens, {
            
            try delete.forEach { try deleteLinkedObjects(of: $0) }
            realm.delete(delete)
            realm.add(save, update: update)
        })
    }
    
    func deleteAll<T: Manageable>(deleteType: T.Type,
                                  predicate: NSPredicate?,
                                  withoutTrigering tokens: [RepositoryNotificationController]) throws {
        
        let objects = try fetch(deleteType, predicate, [])
        let realm = try safeRealm()
        try safePerform(withoutTriggering: tokens, {
            
            try objects.forEach { try deleteLinkedObjects(of: $0) }
            realm.delete(objects)
        })
    }
    
    func perform(updateAction closure: () throws -> Void) throws {
        
        try safePerform { try closure() }
    }
    
    func reset()  throws {
        
        let realm = try safeRealm()
        try safePerform { realm.deleteAll() }
    }
    
    func watch<T: Manageable>(for model: T.Type,
                              _ predicate: NSPredicate?,
                              _ sorted: [Sorted]) throws -> RepositoryNotificationToken<T> {
        
        let realm = try safeRealm()

        let objects = realm.objects(model).filter(predicate).sort(sorted)
        let observable = RepositoryObservable<RepositoryNotificationCase<T>>()
        
        let token = objects.observe { changes in
            
            switch changes {
                
            case .initial(let new):
                observable.fulfill?(RepositoryNotificationCase.initial(new.filter(predicate).sort(sorted).map { $0 }))
            case .update(let new, let deletions, let insertions, let modifications):
                observable.fulfill?(.update(new.map { $0 }, deletions, insertions, modifications))
            break
            case .error(let error):
                observable.reject?(error)
            }
        }
        
        return RepositoryNotificationToken(controller: token,
                                           observable: observable,
                                           current: objects.filter(predicate).sort(sorted).map { $0 })
    }
    
    func watch<T, U: ManageableRepresented>(
        for model: T.Type,
        representedType: U.Type,
        _ predicate: NSPredicate?,
        _ sorted: [Sorted]) throws -> RepositoryNotificationToken<U> where U.RepresentedType == T {
    
        let realm = try safeRealm()
        let objects = realm.objects(model)
        let observable = RepositoryObservable<RepositoryNotificationCase<U>>()
        
        let token = objects.observe { changes in
            
            switch changes {
                
            case .initial(let new):
                let values = (try? new.filter(predicate).sort(sorted)
                    .map { $0 }
                    .map(to: representedType)) ?? []
                observable.fulfill?(RepositoryNotificationCase.initial(values))
            case .update(let new, let deletions, let insertions, let modifications):
                let values = (try? new.filter(predicate).sort(sorted)
                    .map { $0 }
                    .map(to: representedType)) ?? []
                observable.fulfill?(RepositoryNotificationCase.update(values, deletions, insertions, modifications))
            case .error(let error):
                observable.reject?(error)
            }
        }
        
        let current = (try? objects.filter(predicate).sort(sorted).map { $0 }.map(to: representedType)) ?? []
        return RepositoryNotificationToken(controller: token,
                                           observable: observable,
                                           current: current)
    }
    
}

// MARK: - RealmRepository + safe
private extension RealmRepository {
    
    func safeRealm() throws -> Realm {
        
        guard let realm = realm else { fatalError("the realm reference is nil") }
        return realm
    }
    
    func safePerform(withoutTriggering tokens: [RepositoryNotificationController] = [],
                     _ block: (() throws -> Void)) throws {
        
        guard let tokens = tokens as? [NotificationToken] else { throw RepositoryError.conversion }
        guard let realm = realm else { fatalError("the realm reference is nil") }
        
        if realm.isInWriteTransaction {
            
            try block()
        }
        else {
            
            do {
                
                try realm.write(withoutNotifying: tokens, block)
            }
            catch {
                
                throw RepositoryError.transaction
            }
        }
    }
    
    func deleteLinkedObjects(of object: Manageable,
                             withoutTrigering tokens: [RepositoryNotificationController] = []) throws {
        
        let objects = object.allRelationships()
        guard !objects.isEmpty else { return }
        
        let realm = try safeRealm()
        try safePerform(withoutTriggering: tokens, {
            
            try objects.forEach { try deleteLinkedObjects(of: $0) }
            realm.delete(objects)
        })
    }
    
}
