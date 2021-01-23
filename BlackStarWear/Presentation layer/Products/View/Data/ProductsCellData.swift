//
//  ProductsCellData.swift
//  BlackStarWear
//
//  Created by Georgy Gorbenko on 19.12.2020.
//

import Foundation
import RxDataSources

protocol ProductsCellData {
    
    var id: String { get }
    var imageUrl: URL? { get }
    var title: String? { get }
    var price: Double { get }
}

struct ProductsCellDataProducer: ProductsCellData, IdentifiableType, Equatable {
    
    typealias Identity = String
    
    var identity: String = UUID().uuidString
    
    var id: String
    var imageUrl: URL?
    var title: String?
    var price: Double
    
    static func ==(lhs: Self, rhs: Self) -> Bool {
        
        return false
    }
}

protocol ProductsSectionData {
    
}

struct ProductsSectionDataProducer: ProductsSectionData, AnimatableSectionModelType {
    
    typealias Item = ProductsCellDataProducer
    typealias Identity = String
    
    var items: [ProductsCellDataProducer]

    var identity: String {
        
        return String(describing: ProductsSectionDataProducer.self)
    }
    
    init(items: [ProductsCellDataProducer]) {
        
        self.items = items
    }
    
    init(original: ProductsSectionDataProducer, items: [ProductsCellDataProducer]) {
        
        self = original
        self.items = items
    }
    
}
