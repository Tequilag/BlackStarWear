//
//  App.swift
//  BlackStarWear
//
//  Created by Georgy Gorbenko on 17.12.2020.
//

import Foundation

enum App {
    
}

// MARK: - Network
extension App {
    
    enum Network {
        
        case config
        
        // MARK: - Public properties
        
        var url: URL { return "\(baseURL)".url! }
        
        // MARK: - Private properties
        
        private var baseURL: String { return "http://blackstarshop.ru/index.php" }
    }
    
}
