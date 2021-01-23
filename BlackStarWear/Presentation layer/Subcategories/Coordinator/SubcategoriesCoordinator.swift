//
//  SubcategoriesCoordinator.swift
//  BlackStarWear
//
//  Created by Georgy Gorbenko on 19.12.2020.
//

import UIKit

class SubcategoriesCoordinator: BaseCoordinator {
    
    // MARK: - Public properties
    
    var onFinish: (() -> Void)?
    
    // MARK: - Private properties
    
    private let categoryId: String
    private weak var controller: SubcategoriesViewController!
    
    // MARK: - Lifecycle
    
    init(categoryId: String, navigationController: UINavigationController) {
        
        self.categoryId = categoryId
        super.init(navigationController: navigationController)
    }
    
    // MARK: Base overrides
    
    override func start() {
        super.start()
        
        AppCoordinator.shared.registerCoordinator(self)
        let controller = SubcategoriesViewController()
        if let input = controller.resolve(input: SubcategoriesCoordinatorInput.self) {
            
            input.setupInitialState(SubcategoriesViewModel.Initial(categoryId: categoryId))
        }
        
        guard var output = controller.resolve(input: SubcategoriesCoordinatorOutput.self) else { return }
        
        output.onFinish = defaultFinish
        
        output.onBackButtonDidTap = defaultFinish
        
        output.onSubcategoryDidSelect = { [weak self] categoryId in
            
            guard let self = self else { return }
            let coordinator = ProductsCoordinator(categoryId: categoryId,
                                                  navigationController: self.navigationController)
            coordinator.start()
        }
        
        navigationController.pushViewController(controller, animated: true)
        self.controller = controller
    }
    
}

// MARK: Private methods
private extension SubcategoriesCoordinator {
    
    func defaultFinish() {
        
        onFinish?()
        navigationController.popViewController(animated: true)
        AppCoordinator.shared.removeCoordinator(self)
    }
    
}
