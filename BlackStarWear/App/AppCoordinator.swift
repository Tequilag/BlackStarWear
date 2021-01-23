//
//  AppCoordinator.swift
//  BlackStarWear
//
//  Created by Georgy Gorbenko on 18.12.2020.
//

import UIKit

class AppCoordinator: Coordinator {

    // MARK: - Public properties
    
    static let shared = AppCoordinator()
    var navigationController: UINavigationController = BaseNavigationViewController()
    
    weak var window: UIWindow?
    
    // MARK: - Private properties
    
    private var coordinators = [AnyObject]()
    
    private init() {}
}

// MARK: - Public methods
extension AppCoordinator {
    
    func registerCoordinator(_ coordinator: AnyObject) {
        
        coordinators.append(coordinator)
    }
    
    func removeCoordinator(_ coordinator: AnyObject) {
        
        coordinators.removeAll(where: { $0 === coordinator })
    }
    
    func start() {
        
        window?.rootViewController = navigationController
        let categoriesCoordinator = CategoriesCoordinator(navigationController: navigationController)
        categoriesCoordinator.start()
    }
    
}
