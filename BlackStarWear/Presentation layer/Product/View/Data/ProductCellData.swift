//
//  ProductCellData.swift
//  BlackStarWear
//
//  Created by Georgy Gorbenko on 19.12.2020.
//

import Foundation
import RxDataSources

protocol ProductCellData {
    
    var imageUrl: URL? { get }
}

struct ProductCellDataProducer: ProductCellData, IdentifiableType, Equatable {
    
    typealias Identity = String
    
    var identity: String = UUID().uuidString
    
    var imageUrl: URL?
    
    static func ==(lhs: Self, rhs: Self) -> Bool {
        
        return false
    }
}

protocol ProductSectionData {
    
}

struct ProductSectionDataProducer: ProductSectionData, AnimatableSectionModelType {
    
    typealias Item = ProductCellDataProducer
    typealias Identity = String
    
    var items: [ProductCellDataProducer]

    var identity: String {
        
        return String(describing: ProductSectionDataProducer.self)
    }
    
    init(items: [ProductCellDataProducer]) {
        
        self.items = items
    }
    
    init(original: ProductSectionDataProducer, items: [ProductCellDataProducer]) {
        
        self = original
        self.items = items
    }
    
}
