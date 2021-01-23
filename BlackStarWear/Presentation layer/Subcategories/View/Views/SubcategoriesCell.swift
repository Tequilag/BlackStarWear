//
//  SubcategoriesCell.swift
//  BlackStarWear
//
//  Created by Georgy Gorbenko on 19.12.2020.
//

import UIKit
import TinyConstraints

class SubcategoriesCell: BSWTableViewCell {
    
    // MARK: - Private properties
    
    private let placeholderImage = AppDesign.Icon.imagePlaceholder.with(size: CGSize(width: 28, height: 28), offset: 14)
    private var model: SubcategoriesCellData?
    
    // MARK: UI
    
    private let iconImageView = BSWImageView()
    private let titleLabel = BSWLabel()
    
    // MARK: - Lifecycle
    
    override init(style: BSWTableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

// MARK: - Public methods
extension SubcategoriesCell {
    
    func fill(model: SubcategoriesCellData) {
        
        self.model = model
        iconImageView.setImage(with: model.imageUrl, placeholderImage: placeholderImage)
        titleLabel.text = model.title
    }
    
}

// MARK: - Private methods
private extension SubcategoriesCell {
    
    func setupUI() {
        
        iconImageView.layer.cornerRadius = 28
        iconImageView.clipsToBounds = true
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.layer.borderWidth = AppDesign.config.borderWidth
        iconImageView.layer.borderColor = AppDesign.Color.separator.cg
        
        titleLabel.font = AppDesign.Font.bold.with(size: 16)
        titleLabel.textColor = AppDesign.Color.title.ui

        let contentStackView = BSWStackView()
        contentStackView.axis = .horizontal
        contentStackView.spacing = 16

        contentView.addSubview(contentStackView)
        contentStackView.edgesToSuperview(insets: AppDesign.config.contentInset, priority: .defaultHigh)
        iconImageView.height(56)
        iconImageView.width(56)
        contentStackView.addArrangedSubview(iconImageView)
        contentStackView.addArrangedSubview(titleLabel)
    }
    
}
