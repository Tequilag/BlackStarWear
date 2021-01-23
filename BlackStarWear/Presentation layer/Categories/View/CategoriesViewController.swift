//
//  CategoriesViewController.swift
//  BlackStarWear
//
//  Created by Georgy Gorbenko on 18.12.2020.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import TinyConstraints

class CategoriesViewController: BaseViewController {
    
    // MARK: - Public properties
    
    // MARK: Bar data source
    
    override var prefersLargeTitles: Bool {
        
        return true
    }
    
    override var navigationBarTitle: String? {
        
        return "Категории".localized()
    }
    
    // MARK: - Private properties
    
    private let disposeBag = DisposeBag()
    private let viewModel = CategoriesViewModel()
    
    private var dataSource : RxTableViewSectionedAnimatedDataSource<CategoriesSectionDataProducer>!
    
    // MARK: UI
    
    private let tableView = BSWTableView()
    private let refreshControl = UIRefreshControl()
    
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
extension CategoriesViewController: ModuleInputConvertible {
    
    func resolve<ModuleType>(input: ModuleType.Type) -> ModuleType? {
        
        return viewModel as? ModuleType
    }
    
}

// MARK: - Private methods
private extension CategoriesViewController {
    
    func setupUI() {
        
        setupTableView()
        setupRxDataSource()
    }
    
    func setupRxDataSource() {
        
        let dataSource = RxTableViewSectionedAnimatedDataSource<CategoriesSectionDataProducer>(
            configureCell: { dataSource, tableView, indexPath, item in
                
                guard let cell = tableView.dequeueReusableCell(
                        withIdentifier: String(describing: CategoriesCell.self),
                        for: indexPath) as? CategoriesCell else { return UITableViewCell() }
                
                cell.fill(model: item)
                
                return cell
            })
        
        self.dataSource = dataSource
        
        viewModel.output.categories.asDriver()
            .map {
                
                [CategoriesSectionDataProducer(items: $0.map { CategoriesCellDataProducer(id: $0.id,
                                                                                          imageUrl: $0.imageUrl,
                                                                                          title: $0.name) })]
            }
            .drive(tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        viewModel.output.isLoading.drive(onNext: { [unowned self] isLoading in
            
            if isLoading {
                
                self.refreshControl.beginRefreshing()
            }
            else {
                
                self.refreshControl.endRefreshing()
            }
        }).disposed(by: disposeBag)

        viewModel.output.error.drive(onNext: { [unowned self] error in
            
            self.showErrorAlert(error: error)
        }).disposed(by: disposeBag)
    }
    
    func setupTableView() {
        
        view.addSubview(tableView)
        tableView.edges(to: view, excluding: .top)
        tableView.topToSuperview(usingSafeArea: false)
        tableView.separatorInset.left = 0
        tableView.addSubview(refreshControl)
        refreshControl.rx
            .controlEvent(.valueChanged)
            .bind(to: viewModel.input.refreshControlDidFireSubject)
            .disposed(by: disposeBag)
        
        tableView.register(CategoriesCell.self, forCellReuseIdentifier: String(describing: CategoriesCell.self))
        
        tableView.rx.modelSelected(CategoriesCellData.self)
            .asDriver()
            .drive(onNext: { [unowned self] model in
                
                self.viewModel.input.modelDidSelectSubject.onNext(model)
                guard let indexPath = self.tableView.indexPathForSelectedRow else { return }
                self.tableView.deselectRow(at: indexPath, animated: true)
            })
            .disposed(by: disposeBag)
    }
    
}
