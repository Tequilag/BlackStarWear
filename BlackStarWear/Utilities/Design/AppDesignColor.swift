//
//  AppDesignColor.swift
//  BlackStarWear
//
//  Created by Georgy Gorbenko on 18.12.2020.
//

import UIKit

extension AppDesign {
    
    enum Color: String {
        
        /// Hex: #111111
        case navigationBarTitle = "co_navigationBarTitle"
        /// Hex: #AEAEAE
        case navigationBarTint = "co_navigationBarTint"
        /// Hex: #AEAEAE
        case navigationTint = "co_navigationTint"
        /// Hex: #FFFFFF
        case navigationBar = "co_navigationBar"
        /// Hex: #000000
        case title = "co_title"
        /// Hex: #000000
        case subtitle = "co_subtitle"
        /// Hex: #E6E6E6
        case separator = "co_separator"
        /// Hex: #9E9E9E
        case info = "co_info"
        /// Hex: #007AFF
        case activeButton = "co_active_button"
        /// Hex: #FFFFFF
        case activeButtonTitle = "co_active_button_title"
        /// Hex: #FFFFFF
        case negativeButton = "co_negative_button"
        /// Hex: #000000
        case negativeButtonTitle = "co_negativee_button_title"
        
        var ui: UIColor {
            
            return UIColor(named: self.rawValue) ?? .black
        }
        
        var cg: CGColor {
            
            return ui.cgColor
        }
        
    }
    
}
