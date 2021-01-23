//
//  CartViewModel.swift
//  BlackStarWear
//
//  Created by Georgy Gorbenko on 19.12.2020.
//

import Foundation
import RxCocoa
import RxSwift

class CartViewModel {
    
    // MARK: - Public properties
    
    var onFinish: (() -> Void)?
    var onBackButtonDidTap: (() -> Void)?
    var onModuleDeinit: (() -> Void)?
    
    var input: Input
    var output: Output
    
    // MARK: - Private properties
    
    private let disposeBag = DisposeBag()
    private let defaultRepository = RepositoryBuilder.default.build()
    private var repositoryToken: RepositoryNotificationToken<CartItemManageable>?
    private var initial: Initial!
    
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

// MARK: - Public methods
extension CartViewModel {
    
    func onViewDidLoad() {
        
        addCartItemsWatcher()
    }
    
}

// MARK: - CartCoordinatorInput
extension CartViewModel: CartCoordinatorInput {
    
    func setupInitialState(_ state: CartViewModel.Initial) {
        
        initial = state
    }
    
}

// MARK: - CartCoordinatorOutput
extension CartViewModel: CartCoordinatorOutput {
    
}

// MARK: - Public type definitions
extension CartViewModel {
    
    struct Input {
        
        let trashButtonTapSubject = PublishSubject<CartCellData>()
        let deleteConfirmationSubject = PublishSubject<(CartCellData, Bool)>()
        let checkoutSubject = PublishSubject<Void>()
    }
    
    struct Output {
        
        let items = BehaviorRelay<[CartItem]>(value: [])
        let deleteConfirmationSubject = PublishSubject<CartCellData>()
        let isCompletedSubject = BehaviorRelay<Bool>(value: false)
    }
    
    struct Initial {
        
        
    }
    
}

// MARK: - Private methods
private extension CartViewModel {
    
    func setupViewModel() {
        
        input.trashButtonTapSubject.subscribe(onNext: { [unowned self] model in
            
            self.output.deleteConfirmationSubject.onNext((model))
        }).disposed(by: disposeBag)
        
        input.deleteConfirmationSubject.subscribe(onNext: { [unowned self] model, delete in
            
            guard delete else { return }
            try? self.defaultRepository.deleteAll(deleteType: CartItemManageable.self,
                                                  predicate: NSPredicate(format: "id=%@", model.id))
        }).disposed(by: disposeBag)
        
        input.checkoutSubject.subscribe(onNext: { [unowned self] in
            
            if self.output.isCompletedSubject.value {
                
                self.onFinish?()
            }
            else {
                
                guard !self.output.items.value.isEmpty else { return }
                try? self.defaultRepository.deleteAll(deleteType: CartItemManageable.self)
                self.output.isCompletedSubject.accept(true)
            }
        }).disposed(by: disposeBag)
    }
    
    func addCartItemsWatcher() {
        
        guard repositoryToken == nil else { return }
        repositoryToken = try? defaultRepository.watch(for: CartItemManageable.self)
        repositoryToken?.observable.update(execute: { [weak self] notification in
            
            guard let self = self else { return }
            switch notification {
            case .initial(let objects):
                let items = (try? objects.map(to: CartItemProducer.self)) ?? []
                self.output.items.accept(items)
            case .update(let objects, _, _, _):
                let items = (try? objects.map(to: CartItemProducer.self)) ?? []
                self.output.items.accept(items)
            }
        })
    }
    
}
