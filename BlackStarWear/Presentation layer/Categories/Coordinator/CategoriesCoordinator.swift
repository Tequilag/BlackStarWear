//
//  CategoriesCoordinator.swift
//  BlackStarWear
//
//  Created by Georgy Gorbenko on 18.12.2020.
//

import Foundation

class CategoriesCoordinator: BaseCoordinator {
    
    private weak var controller: CategoriesViewController!
    
    override func start() {
        super.start()
        
        AppCoordinator.shared.registerCoordinator(self)
        let controller = CategoriesViewController()
        guard var output = controller.resolve(input: CategoriesCoordinatorOutput.self) else { return }
        
        output.onFinish = defaultFinish
        
        output.onBackButtonDidTap = defaultFinish
        
        output.onCategoryDidSelect = { [weak self] categoryId in
            
            guard let self = self else { return }
            let coordinator = SubcategoriesCoordinator(categoryId: categoryId,
                                                       navigationController: self.navigationController)
            coordinator.start()
        }
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
private extension CategoriesCoordinator {
    
    func defaultFinish() {
        
        navigationController.popViewController(animated: true)
        AppCoordinator.shared.removeCoordinator(self)
    }
    
}
