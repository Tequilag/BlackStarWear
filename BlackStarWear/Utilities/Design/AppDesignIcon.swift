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
        
        func icon(number: Int,
                  size: CGSize,
                  iconColor: UIColor = .white,
                  numberBackgroundColor: UIColor = .red) -> UIImage {
        
            let mainIcon = self.with(size: size).changeColor(with: iconColor)
            
            if number > 0 {
                
                let attributes = [NSAttributedString.Key.font: AppDesign.Font.bold.with(size: 9),
                                  NSAttributedString.Key.foregroundColor: UIColor.white]
                
                let totalSize = CGSize(width: size.width + 3, height: size.height + 6)
                let numberIconSize = CGSize(width: 14, height: 14)
                let circlePoint = CGPoint(x: totalSize.width - numberIconSize.width, y: 0)
                let numberString: NSString = "\(number)" as NSString
                let numberStringSize = numberString.size(withAttributes: attributes)
                let newIcon = UIGraphicsImageRenderer(size: totalSize).image { context in
                    
                    mainIcon.draw(in: CGRect(origin: CGPoint(x: 0, y: totalSize.height - mainIcon.size.height),
                                             size: mainIcon.size))
                    let coloredCircle = numberBackgroundColor.image(size: numberIconSize,
                                                                    cornerRadius: numberIconSize.height / 2.0)
                    coloredCircle.draw(in: CGRect(origin: circlePoint, size: coloredCircle.size))
                    let numberPoint = CGPoint(
                        x: circlePoint.x - (numberStringSize.width / 2.0) + numberIconSize.width / 2.0,
                        y: circlePoint.y - (numberStringSize.height / 2.0) + numberIconSize.height / 2.0)
                    numberString.draw(in: CGRect(origin: numberPoint, size: numberStringSize),
                                      withAttributes: attributes)
                }
                return newIcon
            }
            
            return mainIcon
        }
        
    }
    
}
