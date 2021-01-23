//
//  CartViewController.swift
//  BlackStarWear
//
//  Created by Georgy Gorbenko on 19.12.2020.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import TinyConstraints

class CartViewController: BaseViewController {
    
    // MARK: - Public properties
    
    // MARK: Bar data source
    
    override var navigationBarTitle: String? {
        
        return "Корзина".localized()
    }
    
    // MARK: - Private properties
    
    private let disposeBag = DisposeBag()
    private let viewModel = CartViewModel()
    private let priceFormatter = PriceFormatter()
    
    private var dataSource : RxTableViewSectionedAnimatedDataSource<CartSectionDataProducer>!
    
    // MARK: UI
    
    private let tableView = BSWTableView()
    private let totalLabel = BSWLabel()
    private let priceLabel = BSWLabel()
    private let checkoutButton = BSWButton()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.onViewDidLoad()
        setupUI()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        checkoutButton.layer.cornerRadius = checkoutButton.frame.height / 2.0
    }
    
    override func backButtonDidTap() {
        super.backButtonDidTap()
     
        viewModel.onBackButtonDidTap?()
    }
    
}

// MARK: - ModuleInputConvertible
extension CartViewController: ModuleInputConvertible {
    
    func resolve<ModuleType>(input: ModuleType.Type) -> ModuleType? {
        
        return viewModel as? ModuleType
    }
    
}

// MARK: - Private methods
private extension CartViewController {
    
    func setupUI() {
        
        setupTableView()
        setupBottomMenu()
        setupRxDataSource()
    }
    
    func setupRxDataSource() {
        
        let dataSource = RxTableViewSectionedAnimatedDataSource<CartSectionDataProducer>(
            configureCell: { [unowned self] dataSource, tableView, indexPath, item in
                
                guard let cell = tableView.dequeueReusableCell(
                        withIdentifier: String(describing: CartCell.self),
                        for: indexPath) as? CartCell else { return UITableViewCell() }
                
                self.setupCartItemCell(cell: cell, model: item)
                
                return cell
            })
        
        self.dataSource = dataSource
        
        viewModel.output.items.asObservable().subscribe(onNext: { [unowned self] items in
            
            let total = NSNumber(value: items.reduce(0, { result, item in result + item.product.price }))
            self.priceLabel.text = self.priceFormatter.string(from: total)
        }).disposed(by: disposeBag)
        
        viewModel.output.items.asDriver()
            .map {
                
                [CartSectionDataProducer(items: $0.map { CartCellDataProducer(id: $0.id,
                                                                              imageUrl: $0.product.imageUrl,
                                                                              name: $0.product.name,
                                                                              size: $0.productOffer.size,
                                                                              colorName: $0.product.colorName,
                                                                              price: $0.product.price) })]
            }
            .drive(tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)

        viewModel.output.deleteConfirmationSubject.subscribe(onNext: { [unowned self] model in
            
            let controller = CartItemConfirmationViewController()
            controller.confirmationSubject
                .map { (model, $0) }
                .bind(to: self.viewModel.input.deleteConfirmationSubject)
                .disposed(by: self.disposeBag)
            self.present(controller, animated: false)
        }).disposed(by: disposeBag)
        
        checkoutButton.rx.tap.bind(to: viewModel.input.checkoutSubject).disposed(by: disposeBag)
        
        viewModel.output.isCompletedSubject.subscribe(onNext: { [unowned self] completed in
            
            let title = completed ? "На главную" : "Оформить заказ".localized()
            self.checkoutButton.setTitle(title, for: .normal)
        }).disposed(by: disposeBag)
    }
    
    func setupCartItemCell(cell: CartCell, model: CartCellData) {
        
        cell.fill(model: model)
        cell.trashButton.rx
            .tap
            .map { model }
            .bind(to: viewModel.input.trashButtonTapSubject)
            .disposed(by: cell.disposeBag)
    }
    
    func setupTableView() {
        
        view.addSubview(tableView)
        tableView.edgesToSuperview(excluding: .bottom)
        tableView.separatorInset.left = 0
        
        tableView.register(CartCell.self, forCellReuseIdentifier: String(describing: CartCell.self))
        tableView.allowsSelection = false
    }
    
    func setupBottomMenu() {
        
        totalLabel.text = "Итого:".localized()
        totalLabel.font = AppDesign.Font.regular.with(size: 16)
        totalLabel.textColor = AppDesign.Color.title.ui
        
        priceLabel.font = AppDesign.Font.regular.with(size: 16)
        priceLabel.textColor = AppDesign.Color.info.ui
        priceLabel.text = priceFormatter.string(from: NSNumber(value: 2900))
        
        let separatorView = UIView()
        separatorView.backgroundColor = AppDesign.Color.separator.ui
        
        checkoutButton.setTitle("Оформить заказ".localized(), for: .normal)
        checkoutButton.titleLabel?.font = AppDesign.Font.bold.with(size: 16)
        checkoutButton.backgroundColor = AppDesign.Color.activeButton.ui
        checkoutButton.tintColor = .white
        checkoutButton.contentEdgeInsets = AppDesign.config.contentInset
        
        
        [totalLabel, priceLabel, separatorView, checkoutButton].forEach {
            
            view.addSubview($0)
        }
        
        totalLabel.topToBottom(of: tableView, offset: AppDesign.config.contentInset.top)
        totalLabel.leftToSuperview(offset: AppDesign.config.contentInset.left)
        totalLabel.rightToLeft(of: priceLabel, offset: -8, relation: .equalOrGreater)
        
        priceLabel.centerY(to: totalLabel)
        priceLabel.rightToSuperview(offset: -AppDesign.config.contentInset.right)
        
        separatorView.edgesToSuperview(excluding: [.top, .bottom])
        separatorView.height(1)
        separatorView.topToBottom(of: totalLabel, offset: 16)
        
        checkoutButton.edgesToSuperview(excluding: [.top, .bottom], insets: AppDesign.config.contentInset)
        checkoutButton.bottomToSuperview(offset: -46)
        checkoutButton.topToBottom(of: separatorView, offset: 24)
    }
    
}
