//
//  ProductSuggectionCell.swift
//  BlackStarWear
//
//  Created by Georgy Gorbenko on 21.12.2020.
//

import UIKit
import TinyConstraints

class ProductSuggectionCell: BSWTableViewCell {
    
    // MARK: - Private properties
    
    private let priceFormatter = PriceFormatter()
    private var model: ProductSuggectionCellData?
    
    // MARK: UI
    
    private let colorNameLabel = BSWLabel()
    private let priceLabel = BSWLabel()
    private let sizeLabel = BSWLabel()
    
    // MARK: - Lifecycle
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

// MARK: - Public methods
extension ProductSuggectionCell {
    
    func fill(model: ProductSuggectionCellData) {
        
        self.model = model
        colorNameLabel.text = model.colorName
        priceLabel.text = priceFormatter.string(from: NSNumber(value: model.price))?.uppercased()
        sizeLabel.text = model.size?.uppercased()
    }
    
}

// MARK: - Private methods
private extension ProductSuggectionCell {
    
    func setupUI() {
        
        let spacing: CGFloat = 8
        
        priceFormatter.maximumFractionDigits = 0
        priceFormatter.currencySymbol = "RUB"

        [colorNameLabel, priceLabel, sizeLabel].forEach { label in
            
            label.font = AppDesign.Font.regular.with(size: 16)
            label.textColor = AppDesign.Color.title.ui
            
            contentView.addSubview(label)
            label.edgesToSuperview(excluding: [.left, .right],
                                   insets: .top(AppDesign.config.contentInset.top)
                                    + .bottom(AppDesign.config.contentInset.bottom))
        }
        
        colorNameLabel.leftToSuperview(offset: AppDesign.config.contentInset.left)
        colorNameLabel.right(to: priceLabel, priceLabel.leftAnchor, offset: -spacing, relation: .equalOrGreater)
        priceLabel.right(to: sizeLabel, sizeLabel.leftAnchor, offset: -spacing)
        sizeLabel.leftToRight(of: contentView, offset: -56)
    }
    
}
