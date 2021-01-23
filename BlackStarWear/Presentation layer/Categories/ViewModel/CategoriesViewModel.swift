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
    
    // MARK: - Private properties
    
    private let disposeBag = DisposeBag()
    private let subjects = Subjects()
    private let defaultRepository = RepositoryBuilder.default.build()
    private let categoriesService = CategoriesService()
    
    // MARK: - Lifecycle
    
    init() {
        
        input = Input()
        output = Output(isLoading: subjects.isLoading.asDriver(onErrorJustReturn: false),
                        error: subjects.error.asDriver(onErrorJustReturn: APIError.common))
        setupViewModel()
    }
    
    deinit {
    
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
    }
    
    struct Output {
        
        let categories = BehaviorRelay<[Category]>(value: [])
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
    
}
