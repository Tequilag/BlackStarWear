//
//  BaseNavigationViewController.swift
//  BlackStarWear
//
//  Created by Georgy Gorbenko on 17.12.2020.
//

import UIKit

// MARK: - Navigation Controller Data Source Protocol
protocol NavigationBarDataSource: class {
    
    var navigationBarTitle: String? { get }
    
    var hidesBackButton: Bool { get }
    
    var hidesNavigationBar: Bool { get }
    
    var isInteractivePopGestureRecognizerEnabled: Bool { get }
    
    var prefersLargeTitles: Bool { get }
    
    func titleView(for navigationBar: UINavigationBar) -> UIView?
    func backItem(for navigationBar: UINavigationBar) -> UIBarButtonItem?
    func leftItems(for navigationBar: UINavigationBar) -> [UIBarButtonItem]?
    func rightItems(for navigationBar: UINavigationBar) -> [UIBarButtonItem]?
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool
}

// MARK: - Navigation Controller Style Data Source Protocol
protocol NavigationBarStyleDataSource {
    
    var barStyle: BaseNavigationViewController.NavigationBarStyle { get set }
    
    var navigationBarColor: UIColor { get set }
    var barTintColor: UIColor { get set }
    var tintColor: UIColor { get set }
    var separatorColor: UIColor { get set }
    
    var barTitleColor: UIColor { get set }
    var barTitleFont: UIFont { get set }
}

class BaseNavigationViewController: UINavigationController {
    
    // MARK: - Navigation bar Style
    
    enum NavigationBarStyle: Int {
        
        case transparent
        case shadowed
        case solid
        case gradient
        case blur
    }
    
    // MARK: - Public properties
    
    override var viewControllers: [UIViewController] {
        didSet {
            
            performNeedsUpdates()
        }
    }
    
    weak var barDataSource: NavigationBarDataSource? {
        didSet {
            
            reloadBarDataSource()
        }
    }
    
    var barStyleDataSource: NavigationBarStyleDataSource? {
        didSet {
            
            reloadBarStyle()
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        
        if #available(iOS 13.0, *) {
            
            return .darkContent
        }
        else {
            
            return .default
        }
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
    }
    
}

// MARK: - Public methods
extension BaseNavigationViewController {
    
    func reloadBarStyle() {
        
        guard let barStyleDataSource = barStyleDataSource else { return }
        let backgroundImage = barStyleDataSource.navigationBarColor
            .image(size: CGSize(width: UIScreen.main.bounds.width, height: 1))
        let separatorImage = barStyleDataSource.separatorColor
            .image(size: CGSize(width: UIScreen.main.bounds.width, height: 1))
        
        if #available(iOS 13.0, *) {

            let navBarAppearance = UINavigationBarAppearance()
            navBarAppearance.configureWithOpaqueBackground()
            navBarAppearance.titleTextAttributes = [.font: barStyleDataSource.barTitleFont,
                                                    .foregroundColor: barStyleDataSource.barTitleColor]
            navBarAppearance.backgroundColor = barStyleDataSource.navigationBarColor
            navBarAppearance.backgroundImage = backgroundImage
            navBarAppearance.shadowImage = separatorImage

            navigationBar.standardAppearance = navBarAppearance
            navigationBar.compactAppearance = navBarAppearance
            navigationBar.scrollEdgeAppearance = navBarAppearance
        }
        
        switch barStyleDataSource.barStyle {
        case .transparent:
            navigationBar.isTranslucent = true
            navigationBar.setBackgroundImage(backgroundImage, for: .default)
            navigationBar.shadowImage = separatorImage
        case .shadowed:
            navigationBar.isTranslucent = false
            navigationBar.setBackgroundImage(backgroundImage, for: .default)
            navigationBar.shadowImage = UIImage()
            navigationBar.layer.shadowOffset = CGSize(width: 0, height: 2)
            navigationBar.layer.shadowRadius = 4
            navigationBar.layer.shadowColor = UIColor.black.cgColor
            navigationBar.layer.shadowOpacity = 0.1
            navigationBar.layer.masksToBounds = false
        case .solid:
            navigationBar.isTranslucent = false
            navigationBar.barStyle = .black
            navigationBar.setBackgroundImage(backgroundImage, for: .default)
            navigationBar.setBackgroundImage(backgroundImage, for: .compactPrompt)
            navigationBar.setBackgroundImage(backgroundImage, for: .compact)
            navigationBar.setBackgroundImage(backgroundImage, for: .defaultPrompt)
            navigationBar.shadowImage = separatorImage
        case .gradient:
            navigationBar.isTranslucent = true
            var navigationFrame = navigationBar.bounds
            navigationFrame.size.height += view.safeAreaInsets.top
            guard let image = gradientImage(for: navigationFrame,
                                            with: barStyleDataSource.navigationBarColor) else { return }
            navigationBar.setBackgroundImage(image, for: .default)
            navigationBar.shadowImage = UIImage()
        case .blur:
            // If you want to use this kind of navigation bar. Please implement what you need. Because in each app
            // implementation can be different because of app architecture.
            navigationBar.isTranslucent = true
            navigationBar.setBackgroundImage(UIImage(), for: .default)
        }
        
        navigationBar.barStyle = .black
        navigationBar.barTintColor = barStyleDataSource.barTintColor
        navigationBar.tintColor = barStyleDataSource.tintColor
        navigationBar.backgroundColor = barStyleDataSource.navigationBarColor
        navigationBar.titleTextAttributes = [.font: barStyleDataSource.barTitleFont,
                                             .foregroundColor: barStyleDataSource.barTitleColor]
        navigationBar.largeTitleTextAttributes = [.font: barStyleDataSource.barTitleFont.withSize(36),
                                                  .foregroundColor: barStyleDataSource.barTitleColor]
    }
    
    func reloadBarDataSource() {
        
        guard let barDataSource = barDataSource else { return }
        guard let last = viewControllers.last else { return }
        
        setNavigationBarHidden(barDataSource.hidesNavigationBar, animated: true)
        interactivePopGestureRecognizer?.isEnabled = barDataSource.isInteractivePopGestureRecognizerEnabled
        interactivePopGestureRecognizer?.delegate = barDataSource.isInteractivePopGestureRecognizerEnabled ? self : nil
        navigationBar.prefersLargeTitles = true
        last.navigationItem.largeTitleDisplayMode = barDataSource.prefersLargeTitles ? .always : .never
        
        guard !barDataSource.hidesNavigationBar else { return }
        
        let leftOffsetItem = UIBarButtonItem(customView: UIView(frame: CGRect(origin: .zero,
                                                                              size: CGSize(width: 1, height: 1))))
        let rightOffsetItem = UIBarButtonItem(customView: UIView(frame: CGRect(origin: .zero,
                                                                               size: CGSize(width: 1, height: 1))))
        
        last.navigationItem.title = barDataSource.navigationBarTitle
        last.navigationItem.titleView = barDataSource.titleView(for: navigationBar)
        last.navigationItem.leftBarButtonItems = [leftOffsetItem] + (barDataSource.leftItems(for: navigationBar) ?? [])
        last.navigationItem.rightBarButtonItems = [rightOffsetItem]
            + (barDataSource.rightItems(for: navigationBar) ?? [])

        guard !barDataSource.hidesBackButton else {
            
            last.navigationItem.hidesBackButton = true
            return
        }
        guard let backItem = barDataSource.backItem(for: navigationBar) else { return }
        
        last.navigationItem.hidesBackButton = true
        if last.navigationItem.leftBarButtonItems != nil {
            
            last.navigationItem.leftBarButtonItems?.insert(backItem, at: 0)
        }
        else {
            
            last.navigationItem.leftBarButtonItems = [backItem]
        }
    }
    
}

// MARK: - UIGestureRecognizerDelegate
extension BaseNavigationViewController: UIGestureRecognizerDelegate {
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        
        if gestureRecognizer == interactivePopGestureRecognizer {
            
            return barDataSource?.gestureRecognizerShouldBegin(gestureRecognizer) ?? false
        }
        return true
    }
    
}

// MARK: - Private methods
private extension BaseNavigationViewController {
    
    func performNeedsUpdates() {
        
        reloadBarStyle()
        reloadBarDataSource()
    }
    
    func gradientImage(for frame: CGRect, with color: UIColor) -> UIImage? {
        
        let gradient = CAGradientLayer()
        
        gradient.startPoint = .zero
        gradient.endPoint = CGPoint(x: 0, y: 1)
        gradient.frame = frame
        gradient.colors = [color.cgColor, color.withAlphaComponent(0.01).cgColor]
        
        UIGraphicsBeginImageContext(gradient.frame.size)
        gradient.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
    
}
