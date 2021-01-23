//
//  SubcategoriesCellData.swift
//  BlackStarWear
//
//  Created by Georgy Gorbenko on 19.12.2020.
//

import Foundation
import RxDataSources

protocol SubcategoriesCellData {
    
    var id: String { get }
    var imageUrl: URL? { get }
    var title: String? { get }
}

struct SubcategoriesCellDataProducer: SubcategoriesCellData, IdentifiableType, Equatable {
    
    typealias Identity = String
    
    var identity: String = UUID().uuidString
    
    var id: String
    var imageUrl: URL?
    var title: String?
    
    static func ==(lhs: Self, rhs: Self) -> Bool {
        
        return false
    }
}

protocol SubcategoriesSectionData {
    
}

struct SubcategoriesSectionDataProducer: SubcategoriesSectionData, AnimatableSectionModelType {
    
    typealias Item = SubcategoriesCellDataProducer
    typealias Identity = String
    
    var items: [SubcategoriesCellDataProducer]

    var identity: String {
        
        return String(describing: SubcategoriesSectionDataProducer.self)
    }
    
    init(items: [SubcategoriesCellDataProducer]) {
        
        self.items = items
    }
    
    init(original: SubcategoriesSectionDataProducer, items: [SubcategoriesCellDataProducer]) {
        
        self = original
        self.items = items
    }
    
}
