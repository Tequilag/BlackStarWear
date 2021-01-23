//
//  RepositoryConfiguration.swift
//  BSW
//
//  Created by Georgy Gorbenko on 09.01.2020.
//

import Foundation

enum RepositoryType: Equatable {
    
    case basic(username: String)
    case basicEncryption(username: String, encryptionKey: Data)
    case inMemory(identifier: String)
    
    static func ==(lhs: RepositoryType, rhs: RepositoryType) -> Bool {
        
        switch (lhs, rhs) {
        case (.basic(let lUsername), .basic(let rUsername)):
            return lUsername == rUsername
        case (.basicEncryption(let lUsername, let lkey), .basicEncryption(let rUsername, let rkey)):
            return lUsername == rUsername && lkey == rkey
        case (.inMemory(let lid), .inMemory(let rid)):
            return lid == rid
        default:
            return false
        }
    }
    
}

protocol RepositoryConfiguration {
    
    var repositoryType: RepositoryType { get }
    /// - See: https://github.com/realm/realm-cocoa/issues/4241 
    var isFileProtection: Bool { get }
    var repositorySchemaVersion: UInt64 { get }

    func repositoryDidBeginMigration(with migration: MigrationController)
}
