//
//  CategoriesViewModel.swift
//  BlackStarWear
//
//  Created by Georgy Gorbenko on 18.12.2020.
//

import Foundation
import RxCocoa
import RxSwift

class CategoriesViewModel {
    
    // MARK: - Public properties
    
    let input: Input
    let output: Output
    
    // MARK: Coordinator output
    
    var onFinish: (() -> Void)?
    var onBackButtonDidTap: (() -> Void)?
    var onModuleDeinit: (() -> Void)?
    var onCategoryDidSelect: ((String) -> Void)?
    var onSubcategoryDidSelect: ((String) -> Void)?
    var onCartButtonTap: (() -> Void)?
    
    // MARK: - Private properties
    
    private let disposeBag = DisposeBag()
    private let subjects = Subjects()
    private let defaultRepository = RepositoryBuilder.default.build()
    private let categoriesService = CategoriesService()
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

// MARK: - CategoriesCoordinatorOutput
extension CategoriesViewModel: CategoriesCoordinatorOutput {
    
}

// MARK: - Public type definitions
extension CategoriesViewModel {
    
    struct Input {
        
        let viewDidLoadSubject = PublishSubject<Void>()
        let refreshControlDidFireSubject = PublishSubject<Void>()
        let modelDidSelectSubject = PublishSubject<CategoriesCellData>()
        let cartTap = BehaviorSubject<Void>(value: ())
    }
    
    struct Output {
        
        let categories = BehaviorRelay<[Category]>(value: [])
        let cartItemsCount = BehaviorRelay<Int>(value: 0)
        let isLoading: Driver<Bool>
        let error: Driver<Error>
    }
    
}

// MARK: - Private type definitions
private extension CategoriesViewModel {
    
    struct Subjects {
        
        let isLoading = PublishSubject<Bool>()
        let error = PublishSubject<Error>()
    }
    
}

// MARK: - Private methods
private extension CategoriesViewModel {
    
    func setupViewModel() {
        
        input.viewDidLoadSubject.subscribe(onNext: { [unowned self] in
            
            self.addCartItemsWathcher()
            self.loadCachedCategories()
            self.reloadCategories()
        }).disposed(by: disposeBag)
        
        input.refreshControlDidFireSubject.subscribe(onNext: { [unowned self] in
            
            self.reloadCategories()
        }).disposed(by: disposeBag)
        
        input.modelDidSelectSubject.subscribe(onNext: { [unowned self] model in
            
            guard let category = self.output.categories.value.first(where: { $0.id == model.id }) else { return }
            
            if category.subcategories.isEmpty {
                
                self.onSubcategoryDidSelect?(model.id)
            }
            else {
                
                self.onCategoryDidSelect?(model.id)
            }
        }).disposed(by: disposeBag)
        
        input.cartTap.subscribe(onNext: { [unowned self] in
            
            self.onCartButtonTap?()
        }).disposed(by: disposeBag)
    }
    
    func loadCachedCategories() {
        
        let categories = (try? defaultRepository
                            .fetch(CategoryManageable.self, [Sorted("sortOrder")])
                            .map(to: CategoryProducer.self)) ?? []
        output.categories.accept(categories)
    }
    
    func reloadCategories() {
        
        subjects.isLoading.onNext(true)
        categoriesService.obtainCategories().done {
            
            self.output.categories.accept($0.sorted(by: { $0.sortOrder < $1.sortOrder }))
            try? self.defaultRepository.save($0.map { CategoryManageable($0) }, update: .all)
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
