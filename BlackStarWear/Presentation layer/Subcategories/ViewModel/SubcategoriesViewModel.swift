//
//  SubcategoriesViewModel.swift
//  BlackStarWear
//
//  Created by Georgy Gorbenko on 19.12.2020.
//

import Foundation
import RxCocoa
import RxSwift

class SubcategoriesViewModel {
    
    // MARK: - Public properties
    
    let input: Input
    let output: Output
    
    // MARK: Coordinator output
    
    var onFinish: (() -> Void)?
    var onBackButtonDidTap: (() -> Void)?
    var onModuleDeinit: (() -> Void)?
    var onSubcategoryDidSelect: ((String) -> Void)?
    var onCartButtonTap: (() -> Void)?
    
    // MARK: - Private properties
    
    private let disposeBag = DisposeBag()
    private let defaultRepository = RepositoryBuilder.default.build()
    private var initial: Initial!
    private var repositoryToken: RepositoryNotificationToken<CartItemManageable>?
    
    // MARK: - Lifecycle
    
    init() {
        
        input = Input()
        output = Output()
        setupViewModel()
    }
    
    deinit {
    
        repositoryToken?.controller.stopWatch()
        repositoryToken = nil
        onModuleDeinit?()
    }
    
}

// MARK: - SubcategoriesCoordinatorInput
extension SubcategoriesViewModel: SubcategoriesCoordinatorInput {
    
    func setupInitialState(_ state: SubcategoriesViewModel.Initial) {
        
        initial = state
    }
    
}

// MARK: - SubcategoriesCoordinatorOutput
extension SubcategoriesViewModel: SubcategoriesCoordinatorOutput {
    
}

// MARK: - Public type definitions
extension SubcategoriesViewModel {
    
    struct Input {
        
        let viewDidLoadSubject = PublishSubject<Void>()
        let modelDidSelectSubject = PublishSubject<SubcategoriesCellData>()
        let cartTap = BehaviorSubject<Void>(value: ())
    }
    
    struct Output {
        
        let subcategories = BehaviorRelay<[Subcategory]>(value: [])
        let categoryNameSubject = BehaviorSubject<String?>(value: nil)
        let cartItemsCount = BehaviorRelay<Int>(value: 0)
    }
    
    struct Initial {
        
        let categoryId: String
    }
    
}

// MARK: - Private methods
private extension SubcategoriesViewModel {
    
    func setupViewModel() {
        
        input.viewDidLoadSubject.subscribe(onNext: { [unowned self] in
            
            self.addCartItemsWathcher()
            self.loadCachedSubcategories()
        }).disposed(by: disposeBag)
        
        input.modelDidSelectSubject.subscribe(onNext: { [unowned self] model in
            
            self.onSubcategoryDidSelect?(model.id)
        }).disposed(by: disposeBag)
        
        input.cartTap.subscribe(onNext: { [unowned self] in
            
            self.onCartButtonTap?()
        }).disposed(by: disposeBag)
    }
    
    func loadCachedSubcategories() {
        
        guard let category = try? defaultRepository
                .fetch(CategoryManageable.self, NSPredicate(format: "id=%@", initial.categoryId))
                .map(to: CategoryProducer.self).first else { return }
        output.subcategories.accept(category.subcategories.sorted(by: { $0.sortOrder < $1.sortOrder }))
        output.categoryNameSubject.onNext(category.name)
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
