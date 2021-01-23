//
//  AppDelegate.swift
//  BlackStarWear
//
//  Created by Georgy Gorbenko on 17.12.2020.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        window = UIWindow(frame: CGRect(origin: .zero, size: UIScreen.main.bounds.size))
        AppCoordinator.shared.window = window
        AppCoordinator.shared.start()
        window?.makeKeyAndVisible()
        return true
    }

}

