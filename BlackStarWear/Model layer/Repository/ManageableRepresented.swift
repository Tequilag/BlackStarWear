//
//  ManageableRepresented.swift
//  BSW
//
//  Created by Georgy Gorbenko on 10.01.2020.
//

import RealmSwift

protocol ManageableRepresented {
    
    associatedtype RepresentedType: Manageable
        
    init(from represented: RepresentedType) throws
}

extension ManageableRepresented {
    
    init?(from represented: RepresentedType?) throws {
        
        guard let represented = represented else { return nil }
        self = try Self.init(from: represented)
    }
    
}

// MARK: - Array + ManageableRepresented
extension Array where Element: Object {
    
    func map<T>(to type: T.Type) throws -> [T] where T: ManageableRepresented, Element == T.RepresentedType {
        
        return try self.map { try T(from: $0) }
    }
    
}
