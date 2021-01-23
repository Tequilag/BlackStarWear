//
//  AppDesignIcon.swift
//  BlackStarWear
//
//  Created by Georgy Gorbenko on 18.12.2020.
//

import UIKit

extension AppDesign {
    
    enum Icon: String {
        
        case back = "\u{eaf8}"
        case imagePlaceholder = "\u{e90d}"
        case trash = "\u{ebee}"
        case cart = "\u{e93a}"
        case close = "\u{eb3f}"
        
        var value: UIImage {
            
            return UIImage()
        }
        
        func with(size: CGSize,
                  iconColor: UIColor = .black,
                  backgroundColor: UIColor = .clear,
                  offset: CGFloat = 0) -> UIImage {
            
            let paragraph = NSMutableParagraphStyle()
            paragraph.alignment = .center
            
            // Taken from FontAwesome.io's Fixed Width Icon CSS
            let fontAspectRatio: CGFloat = 1.28571429
            let fontSize = min(size.width / fontAspectRatio, size.height)
            let font = UIFont(name: "icomoon", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize, weight: .bold)
            let size = CGSize(width: size.width + offset, height: size.height + offset)
            let attributedString = NSAttributedString(
                string: self.rawValue,
                attributes: [
                    NSAttributedString.Key.font: font,
                    NSAttributedString.Key.foregroundColor: iconColor,
                    NSAttributedString.Key.backgroundColor: backgroundColor,
                    NSAttributedString.Key.paragraphStyle: paragraph
                ]
            )
            UIGraphicsBeginImageContextWithOptions(size, false , 0.0)
            attributedString.draw(in: CGRect(x: 0,
                                             y: (size.height - fontSize) / 2,
                                             width: size.width,
                                             height: fontSize))
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return image!.withRenderingMode(.alwaysTemplate)
        }
    }
}
