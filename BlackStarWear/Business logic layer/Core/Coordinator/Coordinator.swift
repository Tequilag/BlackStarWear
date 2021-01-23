//
//  Coordinator.swift
//  BlackStarWear
//
//  Created by Georgy Gorbenko on 18.12.2020.
//

import UIKit

protocol Coordinator: class {
    
    var navigationController: UINavigationController { get }
    
    func start()
}

class BaseCoordinator: Coordinator {
    
    // MARK: - Public properties
    
    var navigationController: UINavigationController
    var childCoordinators: [Coordinator] = []
    
    // MARK: - Init
    
    init(navigationController: UINavigationController) {
        
        self.navigationController = navigationController
    }
    
    // MARK: - Public methods
    
    func start() {}
    
    func addDependency(_ coordinator: Coordinator) {
        
        guard !childCoordinators.contains(where: { $0 === coordinator }) else { return }
        childCoordinators.append(coordinator)
    }
    
    func removeDependency(_ coordinator: Coordinator?) {
        
        guard childCoordinators.isEmpty == false,
            let coordinator = coordinator
            else { return }
        
        if let coordinator = coordinator as? BaseCoordinator, !coordinator.childCoordinators.isEmpty {
            
            coordinator.childCoordinators
                .filter({ $0 !== coordinator })
                .forEach({ coordinator.removeDependency($0) })
        }
        for (index, element) in childCoordinators.enumerated() where element === coordinator {
            
            childCoordinators.remove(at: index)
            break
        }
    }
    
}
