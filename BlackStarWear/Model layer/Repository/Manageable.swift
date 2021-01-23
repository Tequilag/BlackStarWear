//
//  Manageable.swift
//  BSW
//
//  Created by Georgy Gorbenko on 09.01.2020.
//

import Foundation
import RealmSwift

typealias Manageable = Object

extension Object {
    
    func allRelationships() -> [Manageable] {
        
        return []
    }
    
}
