//
//  ProductsViewModel.swift
//  BlackStarWear
//
//  Created by Georgy Gorbenko on 19.12.2020.
//

import Foundation
import RxCocoa
import RxSwift

class ProductsViewModel {
    
    // MARK: - Public properties
    
    let input: Input
    let output: Output
    
    // MARK: Coordinator output
    
    var onFinish: (() -> Void)?
    var onBackButtonDidTap: (() -> Void)?
    var onModuleDeinit: (() -> Void)?
    var onProductDidSelect: ((String) -> Void)?
    var onCartButtonTap: (() -> Void)?
    
    // MARK: - Private properties
    
    private let disposeBag = DisposeBag()
    private let subjects = Subjects()
    private let defaultRepository = RepositoryBuilder.default.build()
    private let productsService = ProductsService()
    private var initial: Initial!
    private var repositoryToken: RepositoryNotificationToken<CartItemManageable>?
    
    // MARK: - Lifecycle
    
    init() {
        
        input = Input()
        output = Output(isLoading: subjects.isLoading.asDriver(onErrorJustReturn: false),
                        error: subjects.error.asDriver(onErrorJustReturn: APIError.common))
        setupViewModel()
    }
    
    deinit {
    
        repositoryToken?.controller.stopWatch()
        repositoryToken = nil
        onModuleDeinit?()
    }
    
}

// MARK: - ProductsCoordinatorInput
extension ProductsViewModel: ProductsCoordinatorInput {
    
    func setupInitialState(_ state: ProductsViewModel.Initial) {
        
        initial = state
    }
    
}

// MARK: - ProductsCoordinatorOutput
extension ProductsViewModel: ProductsCoordinatorOutput {
    
}

// MARK: - Public type definitions
extension ProductsViewModel {
    
    struct Input {
        
        let viewDidLoadSubject = PublishSubject<Void>()
        let refreshControlDidFireSubject = PublishSubject<Void>()
        let modelDidSelectSubject = PublishSubject<ProductsCellData>()
        let cartTap = BehaviorSubject<Void>(value: ())
    }
    
    struct Output {
        
        let title: BehaviorRelay<String?> = BehaviorRelay(value: "Товары".localized())
        let products = BehaviorRelay<[Product]>(value: [])
        let isLoading: Driver<Bool>
        let error: Driver<Error>
        let cartItemsCount = BehaviorRelay<Int>(value: 0)
    }
    
    struct Initial {
        
        let categoryId: String
    }
    
}

// MARK: - Private type definitions
private extension ProductsViewModel {
    
    struct Subjects {
        
        let isLoading = PublishSubject<Bool>()
        let error = PublishSubject<Error>()
    }
    
}

// MARK: - Private methods
private extension ProductsViewModel {
    
    func setupViewModel() {
        
        input.viewDidLoadSubject.subscribe(onNext: { [unowned self] in
            
            self.addCartItemsWathcher()
            self.loadCachedProducts()
            self.loadCachedCategory()
            self.reloadProducts()
        }).disposed(by: disposeBag)
        
        input.refreshControlDidFireSubject.subscribe(onNext: { [unowned self] in
            
            self.reloadProducts()
        }).disposed(by: disposeBag)
        
        input.modelDidSelectSubject.subscribe(onNext: { [unowned self] model in
            
            self.onProductDidSelect?(model.id)
        }).disposed(by: disposeBag)
        
        input.cartTap.subscribe(onNext: { [unowned self] in
            
            self.onCartButtonTap?()
        }).disposed(by: disposeBag)
    }
    
    func loadCachedCategory() {
        
        if let category = try? defaultRepository
            .fetch(SubcategoryManageable.self, NSPredicate(format: "id=%@", initial.categoryId))
            .map(to: SubcategoryProducer.self).first {
            
            output.title.accept(category.name)
        }
        else if let category = try? defaultRepository
            .fetch(CategoryManageable.self, NSPredicate(format: "id=%@", initial.categoryId))
            .map(to: CategoryProducer.self).first {
        
            output.title.accept(category.name)
        }
    }
    
    func loadCachedProducts() {
        
        guard let products = try? defaultRepository
                .fetch(ProductManageable.self,
                       NSPredicate(format: "categoryId=%@", initial.categoryId),
                       [Sorted("sortOrder")])
                .map(to: ProductProducer.self) else { return }
        output.products.accept(products)
    }
    
    func reloadProducts() {
        
        subjects.isLoading.onNext(true)
        productsService.obtainProducts(categoryId: initial.categoryId).done {
            
            self.output.products.accept($0.sorted(by: { $0.sortOrder < $1.sortOrder }))
            try? self.defaultRepository.save($0.map { ProductManageable($0) }, update: .all)
        }
        .ensure {
            
            self.subjects.isLoading.onNext(false)
        }
        .catch { error in
            
            self.subjects.error.onNext(error)
        }
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
