//
//  Category.swift
//  BlackStarWear
//
//  Created by Georgy Gorbenko on 18.12.2020.
//

import Foundation
import RealmSwift

protocol Category: ServerResponse {
    
    var id: String { get }
    var imageUrl: URL? { get }
    var name: String? { get }
    var sortOrder: Int { get }
    var subcategories: [Subcategory] { get }
}

struct CategoryProducer: Category, ManageableRepresented {
    
    var id: String
    var imageUrl: URL?
    var name: String?
    var sortOrder: Int
    var subcategories: [Subcategory]
    
    private enum CodingKeys: String, CodingKey {
        
        case imageUrl = "image"
        case name = "name"
        case sortOrder = "sortOrder"
        case subcategories = "subcategories"
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
        subcategories = try container.decode([SubcategoryProducer].self, forKey: .subcategories)
    }
    
    typealias RepresentedType = CategoryManageable
    
    init(from represented: RepresentedType) throws {
        
        id = represented.id
        name = represented.name
        imageUrl = represented.rawImageUrl?.url
        sortOrder = represented.sortOrder
        subcategories = try represented.subcategories.map(to: SubcategoryProducer.self)
    }
    
}

class CategoryManageable: Manageable {
    
    override class func primaryKey() -> String? { return "id" }
    
    var subcategories: [SubcategoryManageable] { return subcategoriesList.map { $0 } }
    
    @objc dynamic var id: String = ""
    @objc dynamic var name: String?
    @objc dynamic var rawImageUrl: String?
    @objc dynamic var sortOrder: Int = 0
    
    private let subcategoriesList = List<SubcategoryManageable>()
    
    convenience init(_ model: Category) {
        self.init()
        
        id = model.id
        name = model.name
        rawImageUrl = model.imageUrl?.absoluteString
        sortOrder = model.sortOrder
        model.subcategories.forEach { subcategoriesList.append(SubcategoryManageable($0)) }
    }
    
}
