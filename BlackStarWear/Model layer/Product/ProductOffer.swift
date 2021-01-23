//
//  ProductOffer.swift
//  BlackStarWear
//
//  Created by Georgy Gorbenko on 21.12.2020.
//

import Foundation
import RealmSwift

protocol ProductOffer: ServerResponse {
    
    var id: String { get }
    var size: String? { get }
    var count: Int { get }
}

struct ProductOfferProducer: ProductOffer, ManageableRepresented {
    
    var id: String
    var size: String?
    var count: Int
    
    private enum CodingKeys: String, CodingKey {
        
        case id = "productOfferID"
        case size = "size"
        case count = "quantity"
    }
    
    init(from decoder: Decoder) throws {
    
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(key: .id)
        size = try? container.decode(key: .size)
        count = try container.decode(key: .count, default: 0)
    }
    
    typealias RepresentedType = ProductOfferManageable
    
    init(from represented: RepresentedType) throws {
        
        id = represented.id
        size = represented.size
        count = represented.count
    }
    
}

class ProductOfferManageable: Manageable {
    
    override class func primaryKey() -> String? { return "id" }
    
    @objc dynamic var id: String = ""
    @objc dynamic var size: String?
    @objc dynamic var count: Int = 0
    
    convenience init(_ model: ProductOffer) {
        self.init()
        
        id = model.id
        size = model.size
        count = model.count
    }
    
}
