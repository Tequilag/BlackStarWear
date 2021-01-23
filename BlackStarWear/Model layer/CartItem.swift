//
//  CartItem.swift
//  BlackStarWear
//
//  Created by Georgy Gorbenko on 21.12.2020.
//

import Foundation
import RealmSwift

protocol CartItem {
    
    var id: String { get }
    var product: Product { get }
    var productOffer: ProductOffer { get }
}

struct CartItemProducer: CartItem, ManageableRepresented {
    
    var id: String
    var product: Product
    var productOffer: ProductOffer

    init(id: String, product: Product, productOffer: ProductOffer) {
        
        self.id = id
        self.product = product
        self.productOffer = productOffer
    }
    
    typealias RepresentedType = CartItemManageable
    
    init(from represented: RepresentedType) throws {
        
        id = represented.id
        product = try ProductProducer(from: represented.product)
        productOffer = try ProductOfferProducer(from: represented.productOffer)
    }
    
}

class CartItemManageable: Manageable {
    
    override class func primaryKey() -> String? { return "id" }
    
    @objc dynamic var id: String = ""
    @objc dynamic var product: ProductManageable!
    @objc dynamic var productOffer: ProductOfferManageable!
    
    convenience init(_ model: CartItem) {
        self.init()
        
        id = model.id
        product = ProductManageable(model.product)
        productOffer = ProductOfferManageable(model.productOffer)
    }
    
}
