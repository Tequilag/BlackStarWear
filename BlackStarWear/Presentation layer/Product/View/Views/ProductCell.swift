//
//  ProductCell.swift
//  BlackStarWear
//
//  Created by Georgy Gorbenko on 19.12.2020.
//

import UIKit
import TinyConstraints

class ProductCell: BSWCollectionViewCell {
    
    // MARK: - Private properties
    
    private let imageSize = CGSize(width: 168, height: 168)
    private lazy var placeholderImage = AppDesign.Icon.imagePlaceholder
        .with(size: CGSize(width: imageSize.width / 2, height: imageSize.height / 2),
              offset: imageSize.height / 4)
    private var model: ProductCellData?
    
    // MARK: UI
    
    private let iconImageView = BSWImageView()
    
    // MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

// MARK: - Public methods
extension ProductCell {
    
    func fill(model: ProductCellData) {
        
        self.model = model
        iconImageView.setImage(with: model.imageUrl, placeholderImage: placeholderImage)
    }
    
}

// MARK: - Private methods
private extension ProductCell {
    
    func setupUI() {
        
        iconImageView.clipsToBounds = true
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.backgroundColor = UIColor.gray.with(alpha: 0.45)

        let contentStackView = BSWStackView()
        contentStackView.axis = .vertical

        contentView.addSubview(contentStackView)
        contentStackView.edgesToSuperview(priority: .defaultHigh)
        contentStackView.addArrangedSubview(iconImageView)
    }
    
}
