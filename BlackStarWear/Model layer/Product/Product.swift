//
//  Product.swift
//  BlackStarWear
//
//  Created by Georgy Gorbenko on 19.12.2020.
//

import Foundation
import RealmSwift

protocol Product: ServerResponse {
    
    var id: String { get }
    var imageUrl: URL? { get }
    var name: String? { get }
    var sortOrder: Int { get }
    var price: Double { get }
    var categoryId: String { get set }
    var images: [ProductImage] { get }
    var offers: [ProductOffer] { get }
    var detail: String? { get }
    var colorName: String? { get }
}

struct ProductProducer: Product, ManageableRepresented {
    
    var id: String
    var imageUrl: URL?
    var name: String?
    var sortOrder: Int
    var price: Double
    var categoryId: String = ""
    var images: [ProductImage]
    var offers: [ProductOffer]
    var detail: String?
    var colorName: String?
    
    private enum CodingKeys: String, CodingKey {
        
        case imageUrl = "mainImage"
        case name = "name"
        case sortOrder = "sortOrder"
        case price = "price"
        case images = "productImages"
        case offers = "offers"
        case detail = "description"
        case colorName = "colorName"
    }
    
    init(from decoder: Decoder) throws {
        
        guard let id = decoder.codingPath.first?.stringValue else {
            
            throw APIError.parsing(type: String(describing: Self.self))
        }
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = id
        let path = try? container.decode(String.self, forKey: .imageUrl)
        imageUrl = "https://blackstar-wear.com/".joined(path, separator: "").url
        name = try? container.decode(key: .name)
        sortOrder = Int(try container.decode(String.self, key: .sortOrder, default: "999")) ?? 999
        price = Double(try container.decode(String.self, key: .price, default: "0")) ?? 0
        images = try container.decode([ProductImageProducer].self, key: .images)
        offers = try container.decode([ProductOfferProducer].self, key: .offers)
        detail = try? container.decode(key: .detail)
        colorName = try? container.decode(key: .colorName)
    }
    
    typealias RepresentedType = ProductManageable
    
    init(from represented: RepresentedType) throws {
        
        id = represented.id
        name = represented.name
        imageUrl = represented.rawImageUrl?.url
        sortOrder = represented.sortOrder
        price = represented.price
        categoryId = represented.categoryId
        images = try represented.images.map(to: ProductImageProducer.self)
        offers = try represented.offers.map(to: ProductOfferProducer.self)
        detail = represented.detail
        colorName = represented.colorName
    }
    
}

class ProductManageable: Manageable {
    
    override class func primaryKey() -> String? { return "id" }
    
    var images: [ProductImageManageable] { return imagesList.map { $0 } }
    var offers: [ProductOfferManageable] { return offersList.map { $0 } }
    
    @objc dynamic var id: String = ""
    @objc dynamic var name: String?
    @objc dynamic var rawImageUrl: String?
    @objc dynamic var sortOrder: Int = 0
    @objc dynamic var price: Double = 0
    @objc dynamic var categoryId: String = ""
    @objc dynamic var detail: String?
    @objc dynamic var colorName: String?
    
    private let imagesList = List<ProductImageManageable>()
    private let offersList = List<ProductOfferManageable>()
    
    convenience init(_ model: Product) {
        self.init()
        
        id = model.id
        name = model.name
        rawImageUrl = model.imageUrl?.absoluteString
        sortOrder = model.sortOrder
        price = model.price
        categoryId = model.categoryId
        detail = model.detail
        colorName = model.colorName
        imagesList.append(objectsIn: model.images.map { ProductImageManageable($0) })
        offersList.append(objectsIn: model.offers.map { ProductOfferManageable($0) })
    }
    
}
