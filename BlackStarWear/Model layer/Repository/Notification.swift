//
//  Notification.swift
//  BSW
//
//  Created by Georgy Gorbenko on 09.01.2020.
//

import Foundation

enum RepositoryNotificationCase<T> {
    
    case initial([T])
    /// Objects, deletions, insertions, updates
    case update([T], [Int], [Int], [Int])
}

struct RepositoryNotificationToken<T> {
    
    let controller: RepositoryNotificationController
    let observable: RepositoryObservable<RepositoryNotificationCase<T>>
    let current: [T]
    
}
