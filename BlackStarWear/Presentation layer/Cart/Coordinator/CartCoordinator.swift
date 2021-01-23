//
//  CartCoordinator.swift
//  BlackStarWear
//
//  Created by Georgy Gorbenko on 19.12.2020.
//

import UIKit

class CartCoordinator: BaseCoordinator {
    
    // MARK: - Public properties
    
    var onFinish: (() -> Void)?
    
    // MARK: - Private properties
    
    private weak var controller: CartViewController!
    
    // MARK: Base overrides
    
    override func start() {
        super.start()
        
        AppCoordinator.shared.registerCoordinator(self)
        let controller = CartViewController()
        let cartNavigationController = BaseNavigationViewController(rootViewController: controller)
        if let input = controller.resolve(input: CartCoordinatorInput.self) {
            
            input.setupInitialState(CartViewModel.Initial())
        }
        
        guard var output = controller.resolve(input: CartCoordinatorOutput.self) else { return }
        
        output.onFinish = { [weak self, weak cartNavigationController] in
            
            guard let self = self else { return }
            cartNavigationController?.dismiss(animated: true, completion: nil)
            self.onFinish?()
            AppCoordinator.shared.removeCoordinator(self)
        }
        
        output.onBackButtonDidTap = { [weak self, weak cartNavigationController] in
            
            guard let self = self else { return }
            cartNavigationController?.dismiss(animated: true, completion: nil)
            AppCoordinator.shared.removeCoordinator(self)
        }
        
        navigationController.present(cartNavigationController, animated: true)
        self.controller = controller
    }
    
}
