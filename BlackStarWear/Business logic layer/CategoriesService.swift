//
//  CategoriesService.swift
//  BlackStarWear
//
//  Created by Georgy Gorbenko on 18.12.2020.
//

import Foundation
import Moya
import PromiseKit

class CategoriesService {
    
    private let provider: MoyaProvider<Request> = ProviderBuilder.buildProvider()
}

// MARK: - Public methods
extension CategoriesService {
    
    func obtainCategories() -> Promise<[Category]> {
        
        return provider.request(target: .categories)
            .map { response -> [Category] in

                let array = try BSWDecoder().decode(DecodedArray<CategoryProducer>.self, from: response.data)
                return array.compactMap { $0 }
        }
    }
    
}


// MARK: - Private type definitions
private extension CategoriesService {
    
    enum Request: APIRequest {
        
        case categories
        
        var path: String {
            
            switch self {
            case .categories:
                return ""
            }
        }
        
        var method: Moya.Method {
            
            switch self {
            case .categories:
                return .get
            }
        }
        
        var task: Task {
            
            switch self {
            case .categories:
                return .requestParameters(parameters: ["route": "api/v1/categories"], encoding: URLEncoding.default)
            }
        }
    }
    
}
