//
//  ModuleInputConvertible.swift
//  BlackStarWear
//
//  Created by Georgy Gorbenko on 18.12.2020.
//

import Foundation

protocol ModuleInputConvertible: AnyObject {
    
    func resolve<ModuleType>(input: ModuleType.Type) -> ModuleType?
}
