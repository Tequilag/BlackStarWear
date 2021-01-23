//
//  CategoriesCellData.swift
//  BlackStarWear
//
//  Created by Georgy Gorbenko on 18.12.2020.
//

import Foundation
import RxDataSources

protocol CategoriesCellData {
    
    var id: String { get }
    var imageUrl: URL? { get }
    var title: String? { get }
}

struct CategoriesCellDataProducer: CategoriesCellData, IdentifiableType, Equatable {
    
    typealias Identity = String
    
    var identity: String = UUID().uuidString
    
    var id: String
    var imageUrl: URL?
    var title: String?
    
    static func ==(lhs: Self, rhs: Self) -> Bool {
        
        return false
    }
}

protocol CategoriesSectionData {
    
}

struct CategoriesSectionDataProducer: CategoriesSectionData, AnimatableSectionModelType {
    
    typealias Item = CategoriesCellDataProducer
    typealias Identity = String
    
    var items: [CategoriesCellDataProducer]

    var identity: String {
        
        return String(describing: CategoriesSectionDataProducer.self)
    }
    
    init(items: [CategoriesCellDataProducer]) {
        
        self.items = items
    }
    
    init(original: CategoriesSectionDataProducer, items: [CategoriesCellDataProducer]) {
        
        self = original
        self.items = items
    }
    
}
