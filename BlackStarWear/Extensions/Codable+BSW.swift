//
//  Codable+BSW.swift
//  BlackStarWear
//
//  Created by Georgy Gorbenko on 18.12.2020.
//

import Foundation

extension KeyedDecodingContainer {
    
    func decode<T: Decodable>(_ type: T.Type = T.self, key: KeyedDecodingContainer.Key) throws -> T {
        
        return try decode(type, forKey: key)
    }
    
    func decode<T: Decodable>(_ type: T.Type = T.self, key: KeyedDecodingContainer.Key, default: T) throws -> T {
        
        return (try? decodeIfPresent(type, forKey: key)) ?? `default`
    }

    func decodeIfPresent<T: Decodable>(_ type: T.Type = T.self, key: KeyedDecodingContainer.Key) throws -> T? {
        
        return try decodeIfPresent(type, forKey: key)
    }
    
}
