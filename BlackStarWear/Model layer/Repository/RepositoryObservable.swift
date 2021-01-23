//
//  RepositoryObservable.swift
//  BSW
//
//  Created by Georgy Gorbenko on 09.01.2020.
//

import Foundation

final class RepositoryObservable<ResultType> {
    
    internal private (set) var fulfill: ((ResultType) -> Void)?
    internal private (set) var reject: ((Error) -> Void)?
    
    @discardableResult
    func update(execute body: @escaping (ResultType) -> Void) -> Self {
        
        fulfill = body
        return self
    }

    @discardableResult
    func `catch`(execute body: @escaping (Error) -> Void) -> Self {
        
        reject = body
        return self
    }
    
}
