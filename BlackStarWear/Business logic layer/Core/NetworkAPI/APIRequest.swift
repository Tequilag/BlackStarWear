//
//  APIRequest.swift
//  BlackStarWear
//
//  Created by Georgy Gorbenko on 18.12.2020.
//

import Foundation
import Moya

protocol APIRequest: TargetType {
    
}

extension APIRequest {
    
    var baseURL: URL {
        
        return App.Network.config.url
    }
    
    var headers: [String : String]? {
        
        return ["Content-Type": "application/json"]
    }
    
    var sampleData: Data {
        
        return Data()
    }
    
}
