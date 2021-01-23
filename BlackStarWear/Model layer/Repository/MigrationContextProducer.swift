//
//  MigrationContextProducer.swift
//  BSW
//
//  Created by Georgy Gorbenko on 09.01.2020.
//

import Foundation

internal struct MigrationContextProducer: MigrationController {
    
    let newSchemaVersion: UInt64
    let oldSchemaVersion: UInt64
    let context: MigrationContext
    
    internal init(_ newSchemaVersion: UInt64, _ oldSchemaVersion: UInt64, _ context: MigrationContext) {
        
        self.newSchemaVersion = newSchemaVersion
        self.oldSchemaVersion = oldSchemaVersion
        self.context = context 
    }
    
}
