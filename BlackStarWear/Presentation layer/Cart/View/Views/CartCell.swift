//
//  CartCell.swift
//  BlackStarWear
//
//  Created by Georgy Gorbenko on 19.12.2020.
//

import UIKit
import TinyConstraints
import RxSwift

class CartCell: BSWTableViewCell {
    
    // MARK: - Public properties
    
    var disposeBag = DisposeBag()
    
    // MARK: UI
    
    let trashButton = BSWButton()
    
    // MARK: - Private properties
    
    private let priceFormatter = PriceFormatter()
    private let imageSize = CGSize(width: 78, height: 78)
    private lazy var placeholderImage = AppDesign.Icon.imagePlaceholder
        .with(size: CGSize(width: imageSize.width / 2, height: imageSize.height / 2), offset: imageSize.height / 4)
    private var model: CartCellData?
    
    // MARK: UI
    
    private let iconImageView = BSWImageView()
    private let nameLabel = BSWLabel()
    private let sizeLabel = BSWLabel()
    private let colorLabel = BSWLabel()
    private let priceLabel = BSWLabel()
    
    // MARK: - Lifecycle
    
    override init(style: BSWTableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        disposeBag = DisposeBag()
    }

}

// MARK: - Public methods
extension CartCell {
    
    func fill(model: CartCellData) {
        
        self.model = model
        iconImageView.setImage(with: model.imageUrl, placeholderImage: placeholderImage)
        nameLabel.text = model.name
        sizeLabel.text = String(format: "Размер: %@".localized(), model.size ?? "")
        colorLabel.text = String(format: "Цвет: %@".localized(), model.colorName ?? "")
        priceLabel.text = priceFormatter.string(from: NSNumber(value: model.price))
    }
    
}

// MARK: - Private methods
private extension CartCell {
    
    func setupUI() {
        
        iconImageView.layer.cornerRadius = AppDesign.config.cornerRadius
        iconImageView.clipsToBounds = true
        iconImageView.contentMode = .scaleAspectFill
        
        nameLabel.font = AppDesign.Font.bold.with(size: 16)
        nameLabel.textColor = AppDesign.Color.title.ui
        
        sizeLabel.font = AppDesign.Font.regular.with(size: 12)
        sizeLabel.textColor = AppDesign.Color.info.ui
        
        colorLabel.font = AppDesign.Font.regular.with(size: 12)
        colorLabel.textColor = AppDesign.Color.info.ui
        
        priceLabel.font = AppDesign.Font.bold.with(size: 16)
        priceLabel.textColor = AppDesign.Color.title.ui
        
        trashButton.setImage(AppDesign.Icon.trash.with(size: CGSize(width: 24, height: 24)), for: .normal)
        trashButton.tintColor = UIColor.gray
        trashButton.contentEdgeInsets = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)

        let contentStackView = BSWStackView()
        contentStackView.axis = .horizontal
        contentStackView.spacing = 10
        contentStackView.alignment = .center
        
        let textStackView = BSWStackView()
        textStackView.axis = .vertical

        contentView.addSubview(contentStackView)
        contentStackView.addArrangedSubview(iconImageView)
        contentStackView.addArrangedSubview(textStackView)
        textStackView.addArrangedSubview(nameLabel)
        textStackView.addArrangedSubview(sizeLabel)
        textStackView.addArrangedSubview(colorLabel)
        textStackView.addArrangedSubview(priceLabel)
        contentStackView.addArrangedSubview(trashButton)
        
        contentStackView.edgesToSuperview(insets: AppDesign.config.contentInset, priority: .defaultHigh)
        iconImageView.height(imageSize.height)
        iconImageView.width(imageSize.width)
        textStackView.setCustomSpacing(6, after: nameLabel)
        textStackView.setCustomSpacing(4, after: sizeLabel)
        textStackView.setCustomSpacing(8, after: colorLabel)
    }
    
}
