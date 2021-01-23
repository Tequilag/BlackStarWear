//
//  CartCoordinatorOutput.swift
//  BlackStarWear
//
//  Created by Georgy Gorbenko on 19.12.2020.
//

import Foundation

protocol CartCoordinatorOutput {
    
    var onFinish: (() -> Void)? { get set }
    var onBackButtonDidTap: (() -> Void)? { get set }
    var onModuleDeinit: (() -> Void)? { get set }
}
