//
//  ProductsViewController.swift
//  BlackStarWear
//
//  Created by Georgy Gorbenko on 19.12.2020.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import TinyConstraints

class ProductsViewController: BaseViewController {
    
    // MARK: - Public properties
    
    // MARK: Bar data source
    
    override var prefersLargeTitles: Bool {
        
        return true
    }
    
    override var navigationBarTitle: String? {
        
        return viewModel.output.title.value
    }
    
    // MARK: - Private properties
    
    private let disposeBag = DisposeBag()
    private let viewModel = ProductsViewModel()
    
    private var dataSource : RxCollectionViewSectionedAnimatedDataSource<ProductsSectionDataProducer>!
    
    // MARK: UI
    
    private let itemSpacing: CGFloat = 8
    private let lineSpacing: CGFloat = 24
    private let collectionViewFlowLayout = UICollectionViewFlowLayout()
    private let refreshControl = UIRefreshControl()
    private lazy var collectionView = BSWCollectionView(frame: .zero, collectionViewLayout: collectionViewFlowLayout)
    
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
    
    override func rightItems(for navigationBar: UINavigationBar) -> [UIBarButtonItem]? {
        
        let button = BSWButton()
        button.setImage(AppDesign.Icon.cart.icon(number: viewModel.output.cartItemsCount.value,
                                                 size: CGSize(width: 20, height: 20),
                                                 iconColor: AppDesign.Color.navigationBarTint.ui),
                        for: .normal)
        button.rx.tap.subscribe(onNext: { [unowned self] in

            self.viewModel.input.cartTap.onNext(())
        }).disposed(by: disposeBag)
        return [UIBarButtonItem(customView: button)]
    }
    
}

// MARK: - ModuleInputConvertible
extension ProductsViewController: ModuleInputConvertible {
    
    func resolve<ModuleType>(input: ModuleType.Type) -> ModuleType? {
        
        return viewModel as? ModuleType
    }
    
}

// MARK: - UICollectionViewDelegateFlowLayout
extension ProductsViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = (collectionView.frame.width
                        - itemSpacing
                        - self.collectionViewFlowLayout.sectionInset.left
                        - self.collectionViewFlowLayout.sectionInset.right) / 2.0
        return CGSize(width: width, height: 248)
    }
    
}

// MARK: - Private methods
private extension ProductsViewController {
    
    func setupUI() {
        
        setupCollectionView()
        setupRxDataSource()
    }
    
    func setupRxDataSource() {
        
        let dataSource = RxCollectionViewSectionedAnimatedDataSource<ProductsSectionDataProducer>
            { dataSource, collectionView, indexPath, model -> UICollectionViewCell in
                
                guard let cell = collectionView
                        .dequeueReusableCell(withReuseIdentifier: String(describing: ProductsCell.self),
                                             for: indexPath) as? ProductsCell else { return UICollectionViewCell() }
                
                cell.fill(model: model)
                
                return cell
            }

        
        self.dataSource = dataSource
        
        viewModel.output.title.asDriver()
            .drive { [unowned self] title in
            
                self.reloadNavigationBar()
            }
            .disposed(by: disposeBag)

        
        viewModel.output.products.asDriver()
            .map {
                
                [ProductsSectionDataProducer(items: $0.map { ProductsCellDataProducer(id: $0.id,
                                                                                      imageUrl: $0.imageUrl,
                                                                                      title: $0.name,
                                                                                      price: $0.price) })]
            }
            .drive(collectionView.rx.items(dataSource: dataSource))
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
        
        viewModel.output.cartItemsCount.subscribe(onNext: { [unowned self] _ in
            
            self.reloadNavigationBar()
        }).disposed(by: disposeBag)
    }
    
    func setupCollectionView() {
        
        view.addSubview(collectionView)
        collectionView.backgroundColor = view.backgroundColor
        collectionView.edges(to: view, excluding: .top)
        collectionView.topToSuperview(usingSafeArea: false)
        collectionView.refreshControl = refreshControl
        collectionViewFlowLayout.sectionInset = AppDesign.config.contentInset
        collectionViewFlowLayout.minimumLineSpacing = lineSpacing
        collectionViewFlowLayout.minimumInteritemSpacing = itemSpacing
        refreshControl.rx
            .controlEvent(.valueChanged)
            .bind(to: viewModel.input.refreshControlDidFireSubject)
            .disposed(by: disposeBag)
        
        collectionView.register(ProductsCell.self, forCellWithReuseIdentifier: String(describing: ProductsCell.self))
        
        collectionView.rx.modelSelected(ProductsCellData.self)
            .asDriver()
            .drive(onNext: { [unowned self] model in
                
                self.viewModel.input.modelDidSelectSubject.onNext(model)
            })
            .disposed(by: disposeBag)
        
        collectionView.rx.setDelegate(self).disposed(by: disposeBag)
    }
    
}
