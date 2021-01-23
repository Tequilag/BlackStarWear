//
//  ProductViewModel.swift
//  BlackStarWear
//
//  Created by Georgy Gorbenko on 19.12.2020.
//

import Foundation
import RxCocoa
import RxSwift

class ProductViewModel {
    
    // MARK: - Public properties
    
    let input: Input
    let output: Output
    
    // MARK: ProductCoordinatorOutput
    
    var onFinish: (() -> Void)?
    var onBackButtonDidTap: (() -> Void)?
    var onModuleDeinit: (() -> Void)?
    var onCartButtonTap: (() -> Void)?
    
    // MARK: - Private properties
    
    private let disposeBag = DisposeBag()
    private let subjects = Subjects()
    private let defaultRepository = RepositoryBuilder.default.build()
    private var initial: Initial!
    private var repositoryToken: RepositoryNotificationToken<CartItemManageable>?
    
    // MARK: - Lifecycle
    
    init() {
        
        input = Input()
        output = Output(productName: subjects.productName.asDriver(onErrorJustReturn: nil),
                        price: subjects.price.asDriver(onErrorJustReturn: 0),
                        detail: subjects.detail.asDriver(onErrorJustReturn: nil))
        setupViewModel()
    }
    
    deinit {
    
        repositoryToken?.controller.stopWatch()
        repositoryToken = nil
        onModuleDeinit?()
    }
    
}

// MARK: - ProductCoordinatorInput
extension ProductViewModel: ProductCoordinatorInput {
    
    func setupInitialState(_ state: ProductViewModel.Initial) {
        
        initial = state
    }
    
}

// MARK: - ProductCoordinatorOutput
extension ProductViewModel: ProductCoordinatorOutput {
    
}

// MARK: - Public type definitions
extension ProductViewModel {
    
    struct Input {
        
        let viewDidLoadSubject = PublishSubject<Void>()
        let suggestionDidSelect = PublishSubject<ProductSuggectionCellData>()
        let cartTap = BehaviorSubject<Void>(value: ())
    }
    
    struct Output {
        
        let images = BehaviorRelay<[ProductCellData]>(value: [])
        let suggestions = BehaviorRelay<[ProductSuggectionCellData]>(value: [])
        let productName: Driver<String?>
        let price: Driver<Double>
        let detail: Driver<String?>
        let cartItemsCount = BehaviorRelay<Int>(value: 0)
    }
    
    struct Initial {
        
        let productId: String
    }
    
}

// MARK: - Private type definitions
private extension ProductViewModel {
    
    struct Subjects {
        
        let productName = PublishSubject<String?>()
        let price = PublishSubject<Double>()
        let detail = PublishSubject<String?>()
    }
    
}

// MARK: - Private methods
private extension ProductViewModel {
    
    func setupViewModel() {
        
        input.viewDidLoadSubject.subscribe(onNext: { [unowned self] in
            
            self.addCartItemsWathcher()
            self.loadCachedProduct()
        }).disposed(by: disposeBag)
        
        input.suggestionDidSelect.subscribe(onNext: { [unowned self] model in
            
            self.addCartItem(suggestion: model)
        }).disposed(by: disposeBag)
        
        input.cartTap.subscribe(onNext: { [unowned self] in
            
            self.onCartButtonTap?()
        }).disposed(by: disposeBag)
    }
    
    func loadCachedProduct() {
        
        guard let product = getProduct() else { return }
        
        output.images.accept(product.images.map { ProductCellDataProducer(imageUrl: $0.imageUrl) })
        output.suggestions.accept(
            
            product.offers.map { ProductSuggectionCellDataProducer(id: $0.id,
                                                                   colorName: product.colorName,
                                                                   price: product.price,
                                                                   size: $0.size) }
        )
        subjects.productName.onNext(product.name)
        subjects.price.onNext(product.price)
        subjects.detail.onNext(product.detail)
    }
    
    func getProduct() -> Product? {
        
        return try? defaultRepository
                .fetch(ProductManageable.self,
                       NSPredicate(format: "id=%@", initial.productId))
                .map(to: ProductProducer.self)
                .first
    }
    
    func getOffer(by id: String) -> ProductOffer? {
        
        return try? defaultRepository
                .fetch(ProductOfferManageable.self,
                       NSPredicate(format: "id=%@", id))
                .map(to: ProductOfferProducer.self)
                .first
    }
    
    func addCartItem(suggestion: ProductSuggectionCellData) {
        
        guard let product = getProduct(), let offer = getOffer(by: suggestion.id) else { return }
        let cartItem = CartItemProducer(id: UUID().uuidString, product: product, productOffer: offer)
        try? defaultRepository.save(CartItemManageable(cartItem), update: .all)
    }
    
    func addCartItemsWathcher() {
        
        guard repositoryToken == nil else { return }
        repositoryToken = try? defaultRepository.watch(for: CartItemManageable.self)
        repositoryToken?.observable.update(execute: { [weak self] notification in
            
            guard let self = self else { return }
            switch notification {
            case .initial(let objects):
                self.output.cartItemsCount.accept(objects.count)
            case .update(let objects, _, _, _):
                self.output.cartItemsCount.accept(objects.count)
            }
        })
    }
    
}
