//
//  ManageableError.swift
//  BlackStarWear
//
//  Created by Georgy Gorbenko on 19.12.2020.
//

import Foundation

enum ManageableError: ModelError {
    
    case convertion(type: String?)
    
    var errorDescription: String? {
        
        switch self {
        case .convertion(let type):
            return "Failed convertion of".localized().joined(type)
        }
    }
}
