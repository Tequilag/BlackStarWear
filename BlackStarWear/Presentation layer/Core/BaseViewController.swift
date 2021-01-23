//
//  BaseViewController.swift
//  BlackStarWear
//
//  Created by Georgy Gorbenko on 17.12.2020.
//

import UIKit

class BaseViewController: UIViewController, NavigationBarDataSource {
    
    // MARK: - Public properties
    
    var navigationBarStyle = NavigationBarDefaultStyle() {
        
        didSet {
            
            navigationController?.barStyleDataSource = navigationBarStyle
        }
    }
    
    override var navigationController: BaseNavigationViewController? {
        
        return super.navigationController as? BaseNavigationViewController
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        
        if #available(iOS 13, *) {
            
            return .darkContent
        }
        return .default
    }
    
    // MARK: Bar data source
    
    var shouldOverrideDataSource = true
    
    var prefersLargeTitles: Bool {
     
        return false
    }
    
    var navigationBarTitle: String? {
        
        return nil
    }
    
    var hidesBackButton: Bool {
        
        return false
    }
    
    var hidesNavigationBar: Bool {
        
        return false
    }
    
    var isInteractivePopGestureRecognizerEnabled: Bool {
        
        return true
    }
    
    // MARK: - Private properties
    
    private var loadFace: UIView?
    
    struct NavigationBarDefaultStyle: NavigationBarStyleDataSource {
        
        var barStyle: BaseNavigationViewController.NavigationBarStyle = .solid
        var prefersLargeTitles = true
        var navigationBarColor = AppDesign.Color.navigationBar.ui
        var barTintColor = AppDesign.Color.navigationBarTint.ui
        var tintColor = AppDesign.Color.navigationTint.ui
        var separatorColor = AppDesign.Color.navigationBarTint.ui
        var barTitleColor = AppDesign.Color.navigationBarTitle.ui
        var barTitleFont = AppDesign.Font.bold.with(size: 16)
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        navigationController?.barStyleDataSource = navigationBarStyle
        
        // It's needed to place here too because if controller is child of navigation controller which is child
        // of page view controller then view will appear will not be triggered on first show.
        if shouldOverrideDataSource {
            
            navigationController?.barDataSource = self
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.barStyleDataSource = navigationBarStyle
        
        if shouldOverrideDataSource {
            
            navigationController?.barDataSource = self
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        navigationController?.barStyleDataSource = navigationBarStyle
        
        if shouldOverrideDataSource {
            
            navigationController?.barDataSource = self
        }
    }
    
    // MARK: - NavigationBarDataSource
    
    func titleView(for navigationBar: UINavigationBar) -> UIView? {
        
        return nil
    }
    
    func backItem(for navigationBar: UINavigationBar) -> UIBarButtonItem? {
        
        let childsCount = navigationController?.viewControllers.count ?? 0
        let image = parent?.presentingViewController != nil
            ? AppDesign.Icon.close.with(size: CGSize(width: 24, height: 24))
            : AppDesign.Icon.back.with(size: CGSize(width: 24, height: 24))
        let backItem = UIBarButtonItem(image: image,
                                       style: .plain,
                                       target: self,
                                       action: #selector(backButtonDidTap))
        
        if childsCount > 1
            || (parent?.presentingViewController != nil || parent?.popoverPresentationController != nil) {
            
            return backItem
        }
        return nil
    }
    
    func leftItems(for navigationBar: UINavigationBar) -> [UIBarButtonItem]? {
        
        return nil
    }
    
    func rightItems(for navigationBar: UINavigationBar) -> [UIBarButtonItem]? {
        
        return nil
    }
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        
        return true
    }
    
    // MARK: - Handlers
    
    @objc func backButtonDidTap() {
        
        
    }
    
}

// MARK: - Public methods
extension BaseViewController {
    
    func hideKeyboard() {
        
        view?.endEditing(true)
    }
    
    func showErrorAlert(error: Error) {
        
        switch error {
        case let error as ModelError:
            let message = [
                    error.errorDescription,
                    error.failureReason,
                    error.recoverySuggestion
                ].compactMap { $0 }
                 .joined(separator: "\n\n")
            showErrorAlert(message: message)
        default:
            showErrorAlert(message: error.localizedDescription)
        }
    }
    
    func showErrorAlert(message: String?) {
        
        let okAction = UIAlertAction(title: "OK".localized(),
                                     style: .default,
                                     handler: nil)
        showAlert(title: "Error".localized(),
                  message: message,
                  actions: [okAction])
    }
    
    func showAlert(title: String?, message: String?) {
        
        let okAction = UIAlertAction(title: "OK".localized(),
                                     style: .default,
                                     handler: nil)
        showAlert(title: title, message: message, actions: [okAction])
    }
    
    func showAlert(title: String?,
                   message: String?,
                   actions: [UIAlertAction]) {
        
        let alertController = UIAlertController(title: title,
                                                message: message,
                                                preferredStyle: .alert)
        actions.forEach { alertController.addAction($0) }
        alertController.modalPresentationStyle = .fullScreen
        present(alertController, animated: true, completion: nil)
    }
    
    func showActionShit(message: String?, actions: [UIAlertAction]) {
        
        showActionShit(title: nil, message: message, actions: actions)
    }
    
    func showActionShit(title: String?, message: String?, actions: [UIAlertAction]) {
        
        let alertController = UIAlertController(title: title,
                                                message: message,
                                                preferredStyle: .actionSheet)
        if !actions.contains(where: { $0.style == .cancel }) {
            
            alertController.addAction(UIAlertAction(title: "Cancel".localized(), style: .cancel, handler: nil))
        }
        actions.forEach { alertController.addAction($0) }
        present(alertController, animated: true, completion: nil)
    }
    
    func reloadNavigationBar() {
        
        navigationController?.reloadBarDataSource()
    }
    
}
