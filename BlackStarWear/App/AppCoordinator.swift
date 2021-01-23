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
        let attributes = [NSAttributedString.Key.font: AppDesign.Font.bold.with(size: 128),
                          NSAttributedString.Key.foregroundColor: UIColor.white]
        
        let totalSize = CGSize(width: 1024, height: 1024)
        let numberString: NSString = """
BLACK
  STAR
 WEAR
""" as NSString
//        let numberString: NSString = "BSW" as NSString
        let numberStringSize = numberString.size(withAttributes: attributes)
        let newIcon = UIGraphicsImageRenderer(size: totalSize).image { context in
            
            let circle = UIColor.black.image(size: totalSize, cornerRadius: 0)
            circle.draw(in: CGRect(origin: .zero, size: circle.size))
            let numberPoint = CGPoint(
                x: (totalSize.width - numberStringSize.width) / 2.0,
                y: (totalSize.height - numberStringSize.height) / 2.0)
            numberString.draw(in: CGRect(origin: numberPoint, size: numberStringSize), withAttributes: attributes)
        }
        let categoriesCoordinator = CategoriesCoordinator(navigationController: navigationController)
        categoriesCoordinator.start()
    }
    
}
