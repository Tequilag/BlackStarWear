//
//  Realm+Repository.swift
//  BSW
//
//  Created by Georgy Gorbenko on 09.01.2020.
//

import Foundation
import RealmSwift

// MARK: - Results
extension Results {
    
    func filter(_ predicate: NSPredicate?) -> Results<Element> {
        
        guard let predicate = predicate else { return self }
        return filter(predicate)
    }
    
    func sort(_ sorted: [Sorted]) -> Results<Element> {
        
        guard !sorted.isEmpty else { return self }
        return self.sorted(by: sorted.map { SortDescriptor(keyPath: $0.key, ascending: $0.ascending) })
    }
    
}

// MARK: - NotificationToken + RepositoryNotificationController
extension NotificationToken: RepositoryNotificationController {
    
    func stopWatch() {
        
        self.invalidate()
    }
    
}

// MARK: - Migration + MigrationContext
extension Migration: MigrationContext {
    
    private func className<T>(of type: T.Type) -> String where T: Manageable {
        
        return type.className()
    }
    
    func forEech<T: Manageable>(for model: T.Type,
                                enumerate: @escaping (DynamicManageable, DynamicManageable) -> Void) {
    
        self.enumerateObjects(ofType: className(of: model)) { (old, new) in
            
            guard let new = new, let old = old else { return }
            enumerate(old, new)
        }
    }
    
    func renameProperty<T: Manageable>(of model: T.Type, from oldName: String, to newName: String) {
        
        self.renameProperty(onType: className(of: model), from: oldName, to: newName)
    }
    
    func create<T: Manageable>(_ model: T.Type) {
        
        self.create(className(of: model))
    }
    
    func delete<T: Manageable>(_ model: T.Type) {
        
        self.deleteData(forType: className(of: model))
    }
    
}

// MARK: - MigrationObject + MigrationManageable
extension MigrationObject: DynamicManageable {
    
    func value<T>(of property: String, type: T.Type) -> T? {
        
        return self[property] as? T
    }
    
    func set(value: Any?, of property: String) {
        
        self[property] = value
    }
    
}
