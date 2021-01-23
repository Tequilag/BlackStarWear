//
//  APIError.swift
//  BlackStarWear
//
//  Created by Georgy Gorbenko on 19.12.2020.
//

import Foundation

enum APIError: ModelError {
    
    case common
    case parsing(type: String?)
    
    var errorDescription: String? {
        
        switch self {
        case .common:
            return "Something gonna wrong".localized()
        case .parsing(let type):
            return "Failed parsing of".localized().joined(type)
        }
    }
    
}
