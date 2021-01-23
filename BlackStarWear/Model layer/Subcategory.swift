//
//  SubSubcategory.swift
//  BlackStarWear
//
//  Created by Georgy Gorbenko on 19.12.2020.
//

import Foundation

protocol Subcategory: ServerResponse {
    
    var id: String { get }
    var imageUrl: URL? { get }
    var name: String? { get }
    var sortOrder: Int { get }
}

struct SubcategoryProducer: Subcategory, ManageableRepresented {
    
    var id: String
    var imageUrl: URL?
    var name: String?
    var sortOrder: Int
    
    private enum CodingKeys: String, CodingKey {
        
        case id = "id"
        case imageUrl = "iconImage"
        case name = "name"
        case sortOrder = "sortOrder"
    }
    
    init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(key: .id, default: String(try container.decode(Int.self, key: .id, default: 999)))
        let path = try? container.decode(String.self, forKey: .imageUrl)
        imageUrl = "https://blackstar-wear.com/".joined(path, separator: "").url
        name = try? container.decode(key: .name)
        sortOrder = Int(try container.decode(String.self, key: .sortOrder, default: "999")) ?? 999
    }
    
    typealias RepresentedType = SubcategoryManageable
    
    init(from represented: RepresentedType) throws {
        
        id = represented.id
        name = represented.name
        imageUrl = represented.rawImageUrl?.url
        sortOrder = represented.sortOrder
    }
    
}

class SubcategoryManageable: Manageable {
    
    override class func primaryKey() -> String? { return "id" }
    
    @objc dynamic var id: String = ""
    @objc dynamic var name: String?
    @objc dynamic var rawImageUrl: String?
    @objc dynamic var sortOrder: Int = 0
    
    convenience init(_ model: Subcategory) {
        self.init()
        
        id = model.id
        name = model.name
        rawImageUrl = model.imageUrl?.absoluteString
        sortOrder = model.sortOrder
    }
    
}
