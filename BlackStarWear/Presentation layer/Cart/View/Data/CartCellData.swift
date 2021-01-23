//
//  CartCellData.swift
//  BlackStarWear
//
//  Created by Georgy Gorbenko on 19.12.2020.
//

import Foundation
import RxDataSources

protocol CartCellData {
    
    var id: String { get }
    var imageUrl: URL? { get }
    var name: String? { get }
    var size: String? { get }
    var colorName: String? { get }
    var price: Double { get }
}

struct CartCellDataProducer: CartCellData, IdentifiableType, Equatable {
    
    typealias Identity = String
    
    var identity: String = UUID().uuidString
    
    var id: String
    var imageUrl: URL?
    var name: String?
    var size: String?
    var colorName: String?
    var price: Double 
    
    static func ==(lhs: Self, rhs: Self) -> Bool {
        
        return false
    }
}

protocol CartSectionData {
    
}

struct CartSectionDataProducer: CartSectionData, AnimatableSectionModelType {
    
    typealias Item = CartCellDataProducer
    typealias Identity = String
    
    var items: [CartCellDataProducer]

    var identity: String {
        
        return String(describing: CartSectionDataProducer.self)
    }
    
    init(items: [CartCellDataProducer]) {
        
        self.items = items
    }
    
    init(original: CartSectionDataProducer, items: [CartCellDataProducer]) {
        
        self = original
        self.items = items
    }
    
}
