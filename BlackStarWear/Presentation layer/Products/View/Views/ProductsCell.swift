//
//  ProductsCell.swift
//  BlackStarWear
//
//  Created by Georgy Gorbenko on 19.12.2020.
//

import UIKit
import TinyConstraints

class ProductsCell: BSWCollectionViewCell {
    
    // MARK: - Private properties
    
    private let imageSize = CGSize(width: 168, height: 168)
    private lazy var placeholderImage = AppDesign.Icon.imagePlaceholder
        .with(size: CGSize(width: imageSize.width / 2, height: imageSize.height / 2),
              offset: imageSize.height / 4)
    private var model: ProductsCellData?
    
    // MARK: UI
    
    private let iconImageView = BSWImageView()
    private let titleLabel = BSWLabel()
    private let priceLabel = BSWLabel()
    private let priceFormatter = PriceFormatter()
    
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
extension ProductsCell {
    
    func fill(model: ProductsCellData) {
        
        self.model = model
        iconImageView.setImage(with: model.imageUrl, placeholderImage: placeholderImage)
        titleLabel.text = model.title
        priceLabel.text = priceFormatter.string(from: NSNumber(value: model.price))
    }
    
}

// MARK: - Private methods
private extension ProductsCell {
    
    func setupUI() {
        
        contentView.backgroundColor = .white

        iconImageView.clipsToBounds = true
        iconImageView.contentMode = .scaleAspectFill
        iconImageView.setContentHuggingPriority(UILayoutPriority(252), for: .vertical)
        
        titleLabel.font = AppDesign.Font.regular.with(size: 11)
        titleLabel.textColor = AppDesign.Color.subtitle.ui
        titleLabel.numberOfLines = 2
        titleLabel.setContentHuggingPriority(UILayoutPriority(251), for: .vertical)
        
        priceLabel.font = AppDesign.Font.bold.with(size: 16)
        priceLabel.textColor = AppDesign.Color.title.ui
        priceLabel.setContentHuggingPriority(UILayoutPriority(253), for: .vertical)

        let contentStackView = BSWStackView()
        contentStackView.axis = .vertical

        contentView.addSubview(contentStackView)
        contentStackView.edgesToSuperview()
        iconImageView.heightToWidth(of: iconImageView)
        contentStackView.addArrangedSubview(titleLabel)
        contentStackView.addArrangedSubview(iconImageView)
        contentStackView.addArrangedSubview(priceLabel)
        
        contentStackView.setCustomSpacing(4, after: titleLabel)
        contentStackView.setCustomSpacing(8, after: iconImageView)
    }
    
}
