//
//  ProductsService.swift
//  BlackStarWear
//
//  Created by Georgy Gorbenko on 19.12.2020.
//

import Foundation
import Moya
import PromiseKit

class ProductsService {
    
    private let provider: MoyaProvider<Request> = ProviderBuilder.buildProvider()
}

// MARK: - Public methods
extension ProductsService {
    
    func obtainProducts(categoryId: String) -> Promise<[Product]> {
        
        return provider.request(target: .products(categoryId: categoryId))
            .map { response -> [Product] in

                do {
                    
                    let array = try BSWDecoder().decode(DecodedArray<ProductProducer>.self, from: response.data)
                    return array.compactMap { product in
                        
                        var product = product
                        product.categoryId = categoryId
                        return product
                    }
                }
                catch {
                    
                    return []
                }
        }
    }
    
}


// MARK: - Private type definitions
private extension ProductsService {
    
    enum Request: APIRequest {
        
        case products(categoryId: String)
        
        var path: String {
            
            switch self {
            case .products:
                return ""
            }
        }
        
        var method: Moya.Method {
            
            switch self {
            case .products:
                return .get
            }
        }
        
        var task: Task {
            
            switch self {
            case .products(let categoryId):
                return .requestParameters(parameters: ["route": "api/v1/products", "cat_id": categoryId],
                                          encoding: URLEncoding.default)
            }
        }
    }
    
}
