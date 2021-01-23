//
//  UIImage+BSW.swift
//  BlackStarWear
//
//  Created by Georgy Gorbenko on 22.12.2020.
//

import UIKit

extension UIImage {
    
    func changeColor(with color: UIColor) -> UIImage {
        
        let image = withRenderingMode(.alwaysTemplate)
        
        return UIGraphicsImageRenderer(size: size).image { rendererContext in
            
            let imageView = UIImageView(image: image)
            imageView.tintColor = color
            imageView.layer.render(in: rendererContext.cgContext)
        }
    }
    
}
