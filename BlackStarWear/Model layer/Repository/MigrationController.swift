//
//  MigrationController.swift
//  BSW
//
//  Created by Georgy Gorbenko on 09.01.2020.
//

import Foundation

protocol MigrationContext {
    
    func forEech<T>(for model: T.Type,
                    enumerate: @escaping  (DynamicManageable, DynamicManageable) -> Void) where T: Manageable
    
    func renameProperty<T>(of model: T.Type, from oldName: String, to newName: String) where T: Manageable
    
    func create<T>(_ model: T.Type) where T: Manageable
    
    func delete<T>(_ model: T.Type) where T: Manageable
}

protocol MigrationController {
    
    var newSchemaVersion: UInt64 { get }
    var oldSchemaVersion: UInt64 { get }
    var context: MigrationContext { get }
}
