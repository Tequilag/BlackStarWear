//
//  AppDesign.swift
//  BlackStarWear
//
//  Created by Georgy Gorbenko on 17.12.2020.
//

import UIKit

/// Here are described all needed resourses and styles which used in the app (fonts, icons, colors, constants)
enum AppDesign {
    
    case config
    
    var cornerRadius: CGFloat { return 10.0 }
    var largeCornerRadius: CGFloat { return 20.0 }
    var borderWidth: CGFloat { return 1.0 }
    
    var leftNavigationItemOffset: CGFloat { return 8.0 }
    var rightNavigationItemOffset: CGFloat { return 4.0 }
    var contentInset: UIEdgeInsets { return UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16) }
}
