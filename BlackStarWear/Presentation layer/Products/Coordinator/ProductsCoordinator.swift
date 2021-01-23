//
//  ProductsCoordinator.swift
//  BlackStarWear
//
//  Created by Georgy Gorbenko on 19.12.2020.
//

import UIKit

class ProductsCoordinator: BaseCoordinator {
    
    // MARK: - Public properties
    
    var onFinish: (() -> Void)?
    
    // MARK: - Private properties
    
    private let categoryId: String
    private weak var controller: ProductsViewController!
    
    // MARK: - Lifecycle
    
    init(categoryId: String, navigationController: UINavigationController) {
        
        self.categoryId = categoryId
        super.init(navigationController: navigationController)
    }
    
    // MARK: Base overrides
    
    override func start() {
        super.start()
        
        let controller = ProductsViewController()
        if let input = controller.resolve(input: ProductsCoordinatorInput.self) {
            
            input.setupInitialState(ProductsViewModel.Initial(categoryId: categoryId))
        }
        
        guard var output = controller.resolve(input: ProductsCoordinatorOutput.self) else { return }
        
        output.onFinish = { [weak self] in
            
            self?.onFinish?()
            self?.navigationController.popViewController(animated: true)
        }
        
        output.onBackButtonDidTap = {
            
            self.navigationController.popViewController(animated: true)
        }
        
        output.onProductDidSelect = { productId in
            
            let coordinator = ProductCoordinator(productId: productId, navigationController: self.navigationController)
            coordinator.start()
        }
        
        navigationController.pushViewController(controller, animated: true)
        self.controller = controller
    }
    
}

// MARK: Private methods
private extension ProductsCoordinator {
    
    func defaultClose() {
        
        onFinish?()
        navigationController.popViewController(animated: true)
        AppCoordinator.shared.removeCoordinator(self)
    }
    
}
