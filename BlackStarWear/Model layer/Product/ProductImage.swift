//
//  ProductImage.swift
//  BlackStarWear
//
//  Created by Georgy Gorbenko on 21.12.2020.
//

import Foundation
import RealmSwift

protocol ProductImage: ServerResponse {
    
    var id: String { get }
    var imageUrl: URL? { get }
    var sortOrder: Int { get }
}

struct ProductImageProducer: ProductImage, ManageableRepresented {
    
    var id: String
    var imageUrl: URL?
    var sortOrder: Int
    
    private enum CodingKeys: String, CodingKey {
        
        case imageUrl = "imageURL"
        case sortOrder = "sortOrder"
    }
    
    init(from decoder: Decoder) throws {
    
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let path = try? container.decode(String.self, forKey: .imageUrl)
        imageUrl = "https://blackstar-wear.com/".joined(path, separator: "").url
        sortOrder = Int(try container.decode(String.self, key: .sortOrder, default: "999")) ?? 999
        id = path ?? "0"
    }
    
    typealias RepresentedType = ProductImageManageable
    
    init(from represented: RepresentedType) throws {
        
        id = represented.id
        imageUrl = represented.rawImageUrl?.url
        sortOrder = represented.sortOrder
    }
    
}

class ProductImageManageable: Manageable {
    
    override class func primaryKey() -> String? { return "id" }
    
    @objc dynamic var id: String = ""
    @objc dynamic var rawImageUrl: String?
    @objc dynamic var sortOrder: Int = 0
    
    convenience init(_ model: ProductImage) {
        self.init()
        
        id = model.id
        rawImageUrl = model.imageUrl?.absoluteString
        sortOrder = model.sortOrder
    }
    
}
