//
//  ProviderBuilder.swift
//  BlackStarWear
//
//  Created by Georgy Gorbenko on 18.12.2020.
//

import Moya

struct ProviderBuilder {
    
    static func buildProvider<T: TargetType>() -> MoyaProvider<T> {
        
        return MoyaProvider<T>()
    }
}
