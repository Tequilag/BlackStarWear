//
//  BSWImageView.swift
//  BlackStarWear
//
//  Created by Georgy Gorbenko on 18.12.2020.
//

import UIKit
import SDWebImage

class BSWImageView: UIImageView {
    
    func setImage(with url: URL?,
                  placeholderImage: UIImage? = AppDesign.Icon.imagePlaceholder
                    .with(size: CGSize(width: 128, height: 128))) {
        
        guard let url = url else {
            
            image = placeholderImage
            return
        }
        sd_setImage(with: url, placeholderImage: placeholderImage)
    }
    
}
