//
//  ProductSuggectionCellData.swift
//  BlackStarWear
//
//  Created by Georgy Gorbenko on 21.12.2020.
//

import Foundation

protocol ProductSuggectionCellData {
    
    var id: String { get }
    var colorName: String? { get }
    var price: Double { get }
    var size: String? { get }
}

struct ProductSuggectionCellDataProducer: ProductSuggectionCellData {
    
    var id: String
    var colorName: String?
    var price: Double
    var size: String?
}
