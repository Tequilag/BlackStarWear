//
//  RepositoryNotification.swift
//  BSW
//
//  Created by Georgy Gorbenko on 09.01.2020.
//

import Foundation

protocol RepositoryNotificationController {
    
    func stopWatch()
}

protocol RepositoryNotification {

    func watch<T: Manageable>(for model: T.Type,
                              _ predicate: NSPredicate?,
                              _ sorted: [Sorted]) throws -> RepositoryNotificationToken<T>
    
    func watch<T, U: ManageableRepresented>(
        for model: T.Type,
        representedType: U.Type,
        _ predicate: NSPredicate?,
        _ sorted: [Sorted]) throws -> RepositoryNotificationToken<U> where U.RepresentedType == T
}

extension RepositoryNotification {
  
    func watch<T: Manageable>(for model: T.Type) throws -> RepositoryNotificationToken<T> {
        
        return try watch(for: model, nil, [])
    }
    
    func watch<T>(for model: T.Type, _ sorted: [Sorted]) throws -> RepositoryNotificationToken<T> where T: Manageable {
        
        return try watch(for: model, nil, sorted)
    }

    func watch<T>(for model: T.Type,
                  _ predicate: NSPredicate?) throws -> RepositoryNotificationToken<T> where T: Manageable {
        
        return try watch(for: model, predicate, [])
    }
    
}
