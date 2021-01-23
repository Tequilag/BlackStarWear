//
//  PriceFormatter.swift
//  BlackStarWear
//
//  Created by Georgy Gorbenko on 21.12.2020.
//

import Foundation

class PriceFormatter: NumberFormatter {
    
    override init() {
        super.init()
        
        locale = Locale(identifier: "ru_RU")
        currencySymbol = "₽"
        maximumFractionDigits = 2
        numberStyle = .currency
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
