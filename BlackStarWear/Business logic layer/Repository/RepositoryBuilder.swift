//
//  RepositoryBuilder.swift
//  BSW
//
//  Created by Georgy Gorbenko on 22.01.2020.
//

import Foundation

enum RepositoryBuilder {
    
    static let schemaVersion: UInt64 = 10
    
    case `default`
    case encrypted
    case inMemory
    
    // MARK: - Configs

    private struct DefaultRepositoryConfiguration: RepositoryConfiguration {
        
        let repositoryType: RepositoryType = .basic(username: "BSWDefault")
        let isFileProtection: Bool = false
        let repositorySchemaVersion: UInt64 = schemaVersion
    }

    private struct InMemoryRepositoryConfiguration: RepositoryConfiguration {
        
        let repositoryType: RepositoryType = .inMemory(identifier: "BSWInMemory")
        let isFileProtection: Bool = false
        let repositorySchemaVersion: UInt64 = schemaVersion
    }
    
    private struct EncryptionRepositoryConfiguration: RepositoryConfiguration {
        
        let repositoryType: RepositoryType
        let isFileProtection: Bool = false
        let repositorySchemaVersion: UInt64 = schemaVersion
        
        init(encryptionKey: Data) {
            
            repositoryType = .basicEncryption(username: "BSW", encryptionKey: encryptionKey)
        }
    }
    
}

// MARK: - Public methods
extension RepositoryBuilder {
    
    func build() -> Repository {
        
        do {
            
            switch self {
            case .default:
                return try RepositoryAPI.newInstance(DefaultRepositoryConfiguration())
            case .inMemory:
                return try RepositoryAPI.newInstance(InMemoryRepositoryConfiguration())
            case .encrypted:
                let encryptionKeyIcloudIdentifier = "BSWRepositoryEncryptionKeyIdentifier"
                let encryptionKeyLength = 64
                let keychainService = KeychainService()
                var encryptionKey = keychainService.getData(encryptionKeyIcloudIdentifier) ?? Data()
                if encryptionKey.isEmpty {
                    
                    encryptionKey.append(Data(count: encryptionKeyLength))
                    
                    _ = encryptionKey.withUnsafeMutableBytes { (pointer: UnsafeMutableRawBufferPointer) -> Int32? in
                        
                        guard let address = pointer.bindMemory(to: UInt8.self).baseAddress else { return nil }
                        return SecRandomCopyBytes(kSecRandomDefault, encryptionKeyLength, address)
                    }
                    keychainService.set(encryptionKey, forKey: encryptionKeyIcloudIdentifier)
                }
                return try RepositoryAPI.newInstance(EncryptionRepositoryConfiguration(encryptionKey: encryptionKey))
            }
        }
        catch {
            
            fatalError("\(self) repository create error: \(error)")
        }
    }
    
}

// MARK: - RepositoryConfiguration + repositoryDidBeginMigration
private extension RepositoryConfiguration {
    
    func repositoryDidBeginMigration(with migration: MigrationController) {
        
        
    }
    
}
