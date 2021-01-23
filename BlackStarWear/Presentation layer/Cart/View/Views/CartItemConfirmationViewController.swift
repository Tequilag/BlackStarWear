//
//  CartItemConfirmationViewController.swift
//  BlackStarWear
//
//  Created by Georgy Gorbenko on 22.12.2020.
//

import UIKit
import TinyConstraints
import RxSwift

class CartItemConfirmationViewController: UIViewController {
    
    // MARK: - Public properties
    
    let confirmationSubject = PublishSubject<Bool>()
    
    // MARK: - Private properties
    
    private let disposeBag = DisposeBag()
    
    // MARK: - Lifecycle
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        modalPresentationStyle = .overCurrentContext
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
}

// MARK: - Private methods
private extension CartItemConfirmationViewController {
    
    func setupUI() {
    
        view.backgroundColor = UIColor.black.with(alpha: 0.45)
        
        let popUpView = UIView()
        popUpView.backgroundColor = .white
        popUpView.layer.cornerRadius = AppDesign.config.cornerRadius
        
        let stackView = BSWStackView()
        stackView.axis = .vertical
        
        let deleteLabel = BSWLabel()
        deleteLabel.font = AppDesign.Font.bold.with(size: 18)
        deleteLabel.textColor = AppDesign.Color.title.ui
        deleteLabel.text = "Удалить товар из корзины?".localized()
        deleteLabel.numberOfLines = 2
        deleteLabel.textAlignment = .center
        
        let yesButton = BSWButton()
        yesButton.setTitle("Да".localized(), for: .normal)
        yesButton.backgroundColor = AppDesign.Color.activeButton.ui
        yesButton.setTitleColor(AppDesign.Color.activeButtonTitle.ui, for: .normal)
        yesButton.layer.cornerRadius = AppDesign.config.cornerRadius
        yesButton.contentEdgeInsets = AppDesign.config.contentInset
        yesButton.rx.tap
            .subscribe(onNext: { [weak self] in
                
                self?.confirmationSubject.onNext(true)
                self?.dismiss(animated: false)
            })
            .disposed(by: disposeBag)
    
        let noButton = BSWButton()
        noButton.setTitle("Нет".localized(), for: .normal)
        noButton.backgroundColor = AppDesign.Color.negativeButton.ui
        noButton.setTitleColor(AppDesign.Color.negativeButtonTitle.ui, for: .normal)
        noButton.layer.cornerRadius = AppDesign.config.cornerRadius
        noButton.layer.borderWidth = AppDesign.config.borderWidth
        noButton.layer.borderColor = UIColor.black.cgColor
        noButton.contentEdgeInsets = AppDesign.config.contentInset
        noButton.rx.tap.asObservable()
            .subscribe(onNext: { [weak self] in
                
                self?.confirmationSubject.onNext(false)
                self?.dismiss(animated: false)
            })
            .disposed(by: disposeBag)
        
        view.addSubview(popUpView)
        popUpView.addSubview(stackView)
        stackView.addArrangedSubview(deleteLabel)
        stackView.addArrangedSubview(yesButton)
        stackView.addArrangedSubview(noButton)
        
        popUpView.edgesToSuperview(excluding: [.top, .bottom], insets: AppDesign.config.contentInset)
        popUpView.centerInSuperview()
        stackView.edgesToSuperview(insets: TinyEdgeInsets(top: 38, left: 28, bottom: 38, right: 28))
        stackView.setCustomSpacing(33, after: deleteLabel)
        stackView.setCustomSpacing(12, after: yesButton)
    }
    
}
