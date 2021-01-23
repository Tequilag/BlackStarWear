//
//  AppDesignFont.swift
//  BlackStarWear
//
//  Created by Georgy Gorbenko on 17.12.2020.
//

import UIKit

extension AppDesign {
    
    enum Font: String {
        
        case bold = "Bold"
        case regular = "Regular"
        case medium = "Medium"
        
        func with(size: CGFloat) -> UIFont {
            
            switch self {
            case .bold:
                return UIFont.systemFont(ofSize: size, weight: .bold)
            case .medium:
                return UIFont.systemFont(ofSize: size, weight: .medium)
            case .regular:
                return UIFont.systemFont(ofSize: size, weight: .regular)
            }
        }
        
    }
    
}
