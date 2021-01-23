//
//  SubcategoriesCoordinatorOutput.swift
//  BlackStarWear
//
//  Created by Georgy Gorbenko on 19.12.2020.
//

import Foundation

protocol SubcategoriesCoordinatorOutput {
    
    var onFinish: (() -> Void)? { get set }
    var onBackButtonDidTap: (() -> Void)? { get set }
    var onModuleDeinit: (() -> Void)? { get set }
    var onSubcategoryDidSelect: ((String) -> Void)? { get set }
    var onCartButtonTap: (() -> Void)? { get set }
}
