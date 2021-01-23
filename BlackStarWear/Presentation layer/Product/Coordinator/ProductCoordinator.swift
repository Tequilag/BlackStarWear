//
//  ProductCoordinator.swift
//  BlackStarWear
//
//  Created by Georgy Gorbenko on 19.12.2020.
//

import UIKit

class ProductCoordinator: BaseCoordinator {
    
    // MARK: - Public properties
    
    var onFinish: (() -> Void)?
    
    // MARK: - Private properties
    
    private let productId: String
    private weak var controller: ProductViewController!
    
    // MARK: - Lifecycle
    
    init(productId: String, navigationController: UINavigationController) {
        
        self.productId = productId
        super.init(navigationController: navigationController)
    }
    
    // MARK: Base overrides
    
    override func start() {
        super.start()
        
        let controller = ProductViewController()
        if let input = controller.resolve(input: ProductCoordinatorInput.self) {
            
            input.setupInitialState(ProductViewModel.Initial(productId: productId))
        }
        
        guard var output = controller.resolve(input: ProductCoordinatorOutput.self) else { return }
        
        AppCoordinator.shared.registerCoordinator(self)
        
        output.onFinish = { [weak self] in
            
            guard let self = self else { return }
            self.onFinish?()
            AppCoordinator.shared.removeCoordinator(self)
            self.navigationController.popViewController(animated: true)
        }
        
        output.onBackButtonDidTap = { [weak self] in
            
            guard let self = self else { return }
            AppCoordinator.shared.removeCoordinator(self)
            self.navigationController.popViewController(animated: true)
        }
        
        output.onCartButtonTap = { [weak self] in
            
            guard let self = self else { return }
            let coordinator = CartCoordinator(navigationController: self.navigationController)
            coordinator.onFinish = {
                
                self.navigationController.popToRootViewController(animated: true)
                AppCoordinator.shared.removeCoordinator(self)
            }
            coordinator.start()
        }
        
        navigationController.pushViewController(controller, animated: true)
        self.controller = controller
    }
    
}
