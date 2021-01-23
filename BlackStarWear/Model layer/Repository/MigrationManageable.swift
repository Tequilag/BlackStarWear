//
//  MigrationManageable.swift
//  BSW
//
//  Created by Georgy Gorbenko on 09.01.2020.
//

import Foundation

protocol DynamicManageable {
    
    func value<T>(of property: String, type: T.Type) -> T?
    
    func set(value: Any?, of property: String)
}
