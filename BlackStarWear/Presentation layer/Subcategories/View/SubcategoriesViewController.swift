//
//  SubcategoriesViewController.swift
//  BlackStarWear
//
//  Created by Georgy Gorbenko on 19.12.2020.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import TinyConstraints

class SubcategoriesViewController: BaseViewController {
    
    // MARK: - Public properties
    
    // MARK: Bar data source
    
    override var prefersLargeTitles: Bool {
        
        return true
    }
    
    override var navigationBarTitle: String? {
        
        return try? viewModel.output.categoryNameSubject.value()
    }
    
    // MARK: - Private properties
    
    private let disposeBag = DisposeBag()
    private let viewModel = SubcategoriesViewModel()
    
    private var dataSource : RxTableViewSectionedAnimatedDataSource<SubcategoriesSectionDataProducer>!
    
    // MARK: UI
    
    private let tableView = BSWTableView()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.input.viewDidLoadSubject.onNext(())
        setupUI()
    }
    
    override func backButtonDidTap() {
        super.backButtonDidTap()
     
        viewModel.onBackButtonDidTap?()
    }
    
}

// MARK: - ModuleInputConvertible
extension SubcategoriesViewController: ModuleInputConvertible {
    
    func resolve<ModuleType>(input: ModuleType.Type) -> ModuleType? {
        
        return viewModel as? ModuleType
    }
    
}

// MARK: - Private methods
private extension SubcategoriesViewController {
    
    func setupUI() {
        
        setupTableView()
        setupRxDataSource()
    }
    
    func setupRxDataSource() {
        
        let dataSource = RxTableViewSectionedAnimatedDataSource<SubcategoriesSectionDataProducer>(
            configureCell: { dataSource, tableView, indexPath, item in
                
                guard let cell = tableView.dequeueReusableCell(
                        withIdentifier: String(describing: SubcategoriesCell.self),
                        for: indexPath) as? SubcategoriesCell else { return UITableViewCell() }
                
                cell.fill(model: item)
                
                return cell
            })
        
        self.dataSource = dataSource
        
        viewModel.output.subcategories.asDriver()
            .map {
                
                [SubcategoriesSectionDataProducer(items: $0.map { SubcategoriesCellDataProducer(id: $0.id,
                                                                                          imageUrl: $0.imageUrl,
                                                                                          title: $0.name) })]
            }
            .drive(tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        viewModel.output.categoryNameSubject.subscribe(onNext: { [unowned self] _ in
            
            self.reloadNavigationBar()
        }).disposed(by: disposeBag)
    }
    
    func setupTableView() {
        
        view.addSubview(tableView)
        tableView.edges(to: view, excluding: .top)
        tableView.topToSuperview(usingSafeArea: false)
        tableView.separatorInset.left = 0
        
        tableView.register(SubcategoriesCell.self, forCellReuseIdentifier: String(describing: SubcategoriesCell.self))
        
        tableView.rx.modelSelected(SubcategoriesCellData.self)
            .asDriver()
            .drive(onNext: { [unowned self] model in
                
                self.viewModel.input.modelDidSelectSubject.onNext(model)
                guard let indexPath = self.tableView.indexPathForSelectedRow else { return }
                self.tableView.deselectRow(at: indexPath, animated: true)
            })
            .disposed(by: disposeBag)
    }
    
}
