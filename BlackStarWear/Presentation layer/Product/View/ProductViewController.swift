//
//  ProductViewController.swift
//  BlackStarWear
//
//  Created by Georgy Gorbenko on 19.12.2020.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import TinyConstraints
import UltraDrawerView

class ProductViewController: BaseViewController {
    
    // MARK: - Public properties
    
    // MARK: Bar data source
    
    // MARK: - Private properties
    
    private let disposeBag = DisposeBag()
    private let viewModel = ProductViewModel()
    private let priceFormatter = PriceFormatter()
    private let collectionViewHeight: CGFloat = 304
    
    private var isUISetupped = false
    private var dataSource : RxCollectionViewSectionedAnimatedDataSource<ProductSectionDataProducer>!
    
    // MARK: UI
    
    private let pageControl = ScrollablePageControl()
    private let titleLabel = BSWLabel()
    private let navigationBackgroundView = UIView()
    private let collectionViewTransparentView = PassableView()
    private let scrollView = BSWScrollView()
    private let contentView = UIView()
    private let contentStackView = BSWStackView()
    private let nameLabel = BSWLabel()
    private let priceLabel = BSWLabel()
    private let priceValueLabel = BSWLabel()
    private let cartButton = BSWButton()
    private let detailLabel = BSWLabel()
    private let collectionViewFlowLayout = UICollectionViewFlowLayout()
    private var scrollViewTopConstraint: NSLayoutConstraint?
    private var navigationBackgroundViewHeightConstraint: NSLayoutConstraint?
    private lazy var collectionView = BSWCollectionView(frame: .zero, collectionViewLayout: collectionViewFlowLayout)
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        viewModel.input.viewDidLoadSubject.onNext(())
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        guard !isUISetupped else { return }
        isUISetupped = true
        additionalUISetup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        titleLabel.isHidden = true
        collectionViewTransparentView.backgroundColor = .clear
        navigationBackgroundView.backgroundColor = .clear
    }
    
    override func backButtonDidTap() {
        super.backButtonDidTap()
     
        viewModel.onBackButtonDidTap?()
    }
    
    override func titleView(for navigationBar: UINavigationBar) -> UIView? {
        
        return titleLabel
    }
    
    override func rightItems(for navigationBar: UINavigationBar) -> [UIBarButtonItem]? {
        
        let button = BSWButton()
        button.setImage(buildCartIcon(with: viewModel.output.cartItemsCount.value), for: .normal)
        button.rx.tap.subscribe(onNext: { [unowned self] in

            self.viewModel.input.cartTap.onNext(())
        }).disposed(by: disposeBag)
        return [UIBarButtonItem(customView: button)]
    }
    
}

// MARK: - ModuleInputConvertible
extension ProductViewController: ModuleInputConvertible {
    
    func resolve<ModuleType>(input: ModuleType.Type) -> ModuleType? {
        
        return viewModel as? ModuleType
    }
    
}

// MARK: - UICollectionViewDelegateFlowLayout
extension ProductViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return collectionView.frame.size
    }
    
}

// MARK: - DrawerViewListener
extension ProductViewController: DrawerViewListener {
    
    func drawerView(_ drawerView: DrawerView,
                    willBeginUpdatingOrigin origin: CGFloat,
                    source: DrawerOriginChangeSource) {
        
        // ..
    }
    
    func drawerView(_ drawerView: DrawerView,
                    didUpdateOrigin origin: CGFloat,
                    source: DrawerOriginChangeSource) {
        
        // ..
    }
    
    func drawerView(_ drawerView: DrawerView,
                    didEndUpdatingOrigin origin: CGFloat,
                    source: DrawerOriginChangeSource) {
        
        // ..
    }
    
    func drawerView(_ drawerView: DrawerView, didChangeState state: DrawerView.State?) {
        
        guard state == .dismissed else { return }
        drawerView.removeFromSuperview()
    }
    
    func drawerView(_ drawerView: DrawerView,
                    willBeginAnimationToState state: DrawerView.State?,
                    source: DrawerOriginChangeSource) {
        
        // ..
    }
    
}

// MARK: - UIScrollViewDelegate
extension ProductViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        guard scrollView === self.scrollView, isUISetupped else { return }
        updateUIOnContentViewMove()
    }
    
}

// MARK: - Private type definitions
private extension ProductViewController {
    
    class TouchableDrawerView: DrawerView {
        
        let disposeBag = DisposeBag()
        
        override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
            
            if !super.point(inside: point, with: event) {
                
                setState(.dismissed, animated: true)
                return true
            }
            return super.point(inside: point, with: event)
        }
        
    }
    
}

// MARK: - Private methods
private extension ProductViewController {
    
    func setupUI() {
        
        setupView()
        setupCollectionView()
        setupScrollView()
        setupRxDataSource()
        setupPageControl()
        view.bringSubviewToFront(navigationBackgroundView)
    }
    
    func setupRxDataSource() {
        
        let dataSource = RxCollectionViewSectionedAnimatedDataSource<ProductSectionDataProducer>
            { dataSource, collectionView, indexPath, model -> UICollectionViewCell in
                
                guard let cell = collectionView
                        .dequeueReusableCell(withReuseIdentifier: String(describing: ProductCell.self),
                                             for: indexPath) as? ProductCell else { return UICollectionViewCell() }
                
                cell.fill(model: model)
                
                return cell
            }

        
        self.dataSource = dataSource
         
        viewModel.output.images.asObservable().subscribe(onNext: { [unowned self] items in
            
            self.pageControl.numberOfPages = items.count
        }).disposed(by: disposeBag)
        
        viewModel.output.images.asDriver()
            .map {
                
                [ProductSectionDataProducer(items: ($0 as? [ProductCellDataProducer]) ?? [])]
            }
            .drive(collectionView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        viewModel.output.productName.asDriver().drive(onNext: { [unowned self] productName in
            
            self.nameLabel.text = productName
            self.titleLabel.text = productName
        }).disposed(by: disposeBag)
        
        viewModel.output.price.asDriver().drive(onNext: { [unowned self] price in
            
            self.priceValueLabel.text = self.priceFormatter.string(from: NSNumber(value: price))
        }).disposed(by: disposeBag)
        
        viewModel.output.detail.asDriver().drive(onNext: { [unowned self] detail in
            
            self.detailLabel.text = detail
        }).disposed(by: disposeBag)
        
        viewModel.output.cartItemsCount.subscribe(onNext: { [unowned self] _ in
            
            self.reloadNavigationBar()
        }).disposed(by: disposeBag)
    }
    
    func setupView() {
        
        view.backgroundColor = .white
        var style = navigationBarStyle
        style.barStyle = .transparent
        style.separatorColor = .clear
        style.navigationBarColor = .clear
        style.tintColor = .white
        navigationBarStyle = style
        
        view.addSubview(navigationBackgroundView)
        navigationBackgroundView.edgesToSuperview(excluding: [.bottom])
        navigationBackgroundViewHeightConstraint = navigationBackgroundView.height(0)
    }
    
    func setupCollectionView() {
        
        collectionView.register(ProductCell.self, forCellWithReuseIdentifier: String(describing: ProductCell.self))
        collectionView.rx.setDelegate(self).disposed(by: disposeBag)
        collectionView.isPagingEnabled = true
        collectionView.backgroundColor = view.backgroundColor
        collectionView.showsHorizontalScrollIndicator = false
        collectionViewFlowLayout.scrollDirection = .horizontal
        collectionViewFlowLayout.minimumInteritemSpacing = 0
        collectionViewFlowLayout.minimumLineSpacing = 0
        
        collectionView.rx.didEndDecelerating.subscribe(onNext: { [unowned self] in
            
            let page = self.collectionView.contentOffset.x / self.collectionView.frame.width
            self.pageControl.setCurrentPage(at: Int(page.rounded(.up)), animated: true)
        }).disposed(by: disposeBag)
    }
    
    func setupPageControl() {
        
        pageControl.bottom(to: collectionView, offset: -32)
        pageControl.centerX(to: collectionView)
        
        pageControl.currentPageIndicatorTintColor = UIColor.green
        pageControl.pageIndicatorTintColor = UIColor.gray
    }
    
    func setupScrollView() {
        
        contentStackView.axis = .vertical
        
        let contentBackrgroundView = UIView()
        contentBackrgroundView.backgroundColor = view.backgroundColor
        
        let separatorView = UIView()
        separatorView.backgroundColor = AppDesign.Color.separator.ui
        
        let priceStackView = BSWStackView()
        priceStackView.axis = .horizontal
        priceStackView.distribution = .equalSpacing
        
        scrollView.contentInsetAdjustmentBehavior = .always
        scrollView.alwaysBounceVertical = true
        scrollView.delegate = self
        
        titleLabel.frame.size = CGSize(width: 200, height: 24)
        titleLabel.text = "Aspen Gold"
        titleLabel.font = AppDesign.Font.bold.with(size: 16)
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center
            
        nameLabel.font = AppDesign.Font.bold.with(size: 36)
        nameLabel.textColor = AppDesign.Color.title.ui
        nameLabel.textAlignment = .center
        nameLabel.numberOfLines = 3
        
        priceLabel.font = AppDesign.Font.regular.with(size: 16)
        priceLabel.textColor = AppDesign.Color.title.ui
        priceLabel.text = "Стоимость:".localized()
        priceLabel.setHugging(.defaultHigh, for: .horizontal)
        
        priceValueLabel.font = AppDesign.Font.medium.with(size: 16)
        priceValueLabel.textColor = AppDesign.Color.subtitle.ui
        
        detailLabel.font = AppDesign.Font.regular.with(size: 16)
        detailLabel.textColor = AppDesign.Color.title.ui
        detailLabel.numberOfLines = 0
        
        cartButton.contentEdgeInsets = AppDesign.config.contentInset
        cartButton.layer.cornerRadius = AppDesign.config.cornerRadius
        cartButton.backgroundColor = .blue
        cartButton.tintColor = .white
        cartButton.setTitle("Добавить в корзину".localized().uppercased(), for: .normal)
        cartButton.titleLabel?.font = AppDesign.Font.regular.with(size: 16)
        cartButton.addTarget(self, action: #selector(cartButtonDidTap(_:)), for: .touchUpInside)
        cartButton.isEnabled = true
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(collectionView)
        contentView.addSubview(pageControl)
        contentView.addSubview(collectionViewTransparentView)
        contentView.addSubview(contentBackrgroundView)
        contentView.addSubview(contentStackView)
        contentStackView.addArrangedSubview(nameLabel)
        contentStackView.addArrangedSubview(separatorView)
        contentStackView.addArrangedSubview(priceStackView)
        priceStackView.addArrangedSubview(priceLabel)
        priceStackView.addArrangedSubview(priceValueLabel)
        contentStackView.addArrangedSubview(cartButton)
        contentStackView.addArrangedSubview(detailLabel)
        
        scrollViewTopConstraint = scrollView.topToSuperview()
        scrollView.edgesToSuperview(excluding: .top)
        contentView.edgesToSuperview(usingSafeArea: false)
        contentView.width(to: scrollView)
        collectionView.edgesToSuperview(excluding: [.top, .bottom])
        collectionView.top(to: view, view.topAnchor)
        collectionView.height(collectionViewHeight)
        collectionViewTransparentView.edges(to: collectionView)
        contentBackrgroundView.edgesToSuperview(excluding: [.bottom, .top])
        contentBackrgroundView.edges(to: contentStackView, excluding: [.left, .right])
        contentStackView.edgesToSuperview(excluding: .top, insets: AppDesign.config.contentInset)
        contentStackView.topToSuperview(offset: collectionViewHeight)
        separatorView.height(1)
        contentStackView.setCustomSpacing(8, after: separatorView)
        contentStackView.setCustomSpacing(16, after: priceStackView)
        contentStackView.setCustomSpacing(28, after: cartButton)
    }
    
    func additionalUISetup() {
        
        scrollViewTopConstraint?.constant = -view.safeAreaInsets.top
        navigationBackgroundViewHeightConstraint?.constant = view.safeAreaInsets.top
        navigationController?.navigationBar.clipsToBounds = true
    }
    
    func updateUIOnContentViewMove() {
        
        let point = scrollView.convert(contentStackView.frame.origin, to: view)
        let maxAlpha: CGFloat = 1
        let color = UIColor.gray
        let safePointY = point.y - view.safeAreaInsets.top
        
        if point.y <= collectionViewHeight {
            
            let translationY = (point.y - collectionViewHeight) / 3.0
            collectionView.transform = CGAffineTransform(translationX: 0, y: translationY)
            pageControl.transform = CGAffineTransform(translationX: 0, y: translationY)
        }
        else {
            
            let scale = max(1, point.y / collectionViewHeight)
            collectionView.transform = CGAffineTransform(scaleX: scale, y: scale)
            pageControl.transform = CGAffineTransform(scaleX: scale, y: scale)
        }
        
        let nameLabelPoint = scrollView.convert(nameLabel.frame.origin, to: view)
        
        titleLabel.frame.origin.y = max(0, collectionViewHeight - abs(nameLabelPoint.y) - view.safeAreaInsets.top / 2)
        titleLabel.isHidden = false
        
        let navigationBackgroundViewAlpha = safePointY <= 0 ? maxAlpha : 0
        let multiplier = 1 / ((collectionViewHeight - view.safeAreaInsets.top) / collectionViewHeight)
        let collectionViewTransparentViewAlpha = max(navigationBackgroundViewAlpha == 0 ? 0 : maxAlpha,
                                                     (maxAlpha - point.y / collectionViewHeight) * multiplier)
        collectionViewTransparentView.backgroundColor = color.with(alpha: collectionViewTransparentViewAlpha)
        navigationBackgroundView.backgroundColor = color.with(alpha: navigationBackgroundViewAlpha)
    }
    
    func showSuggestions() {

        let tableView = BSWTableView()
        let drawerView = TouchableDrawerView(scrollView: tableView, delegate: self, headerView: UIView())
        drawerView.availableStates = [.top, .dismissed]
        drawerView.topPosition = .fromBottom(256)
        drawerView.containerView.backgroundColor = .white
        drawerView.backgroundColor = UIColor.black.with(alpha: 0.45)
        drawerView.setState(.dismissed, animated: false)
        drawerView.addListener(self)
    
        view.addSubview(drawerView)
        drawerView.edgesToSuperview()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            
            drawerView.setState(.top, animated: true)
        }
        
        let cellId = String(describing: ProductSuggectionCell.self)
        tableView.register(ProductSuggectionCell.self, forCellReuseIdentifier: cellId)
        
        viewModel.output.suggestions.bind(
            to: tableView.rx.items(cellIdentifier: cellId,
                                   cellType: ProductSuggectionCell.self)) { index, model, cell in
        
                cell.fill(model: model)
            }
            .disposed(by: drawerView.disposeBag)
        
        tableView.rx.modelSelected(ProductSuggectionCellData.self)
            .asDriver()
            .drive(onNext: { [unowned self] model in
                
                self.viewModel.input.suggestionDidSelect.onNext(model)
                drawerView.removeFromSuperview()
            })
            .disposed(by: drawerView.disposeBag)
    }
    
    func buildCartIcon(with number: Int) -> UIImage? {
        
        let cartIcon = AppDesign.Icon.cart.with(size: CGSize(width: 20, height: 20)).changeColor(with: .white)
        
        if number > 0 {
            
            let attributes = [NSAttributedString.Key.font: AppDesign.Font.bold.with(size: 9),
                              NSAttributedString.Key.foregroundColor: UIColor.white]
            
            let totalSize = CGSize(width: 23, height: 26)
            let numberIconSize = CGSize(width: 14, height: 14)
            let circlePoint = CGPoint(x: totalSize.width - numberIconSize.width, y: 0)
            let numberString: NSString = "\(number)" as NSString
            let numberStringSize = numberString.size(withAttributes: attributes)
            let newIcon = UIGraphicsImageRenderer(size: totalSize).image { context in
                
                cartIcon.draw(in: CGRect(origin: CGPoint(x: 0, y: totalSize.height - cartIcon.size.height),
                                         size: cartIcon.size))
                let redCircle = UIColor.red.image(size: numberIconSize, cornerRadius: numberIconSize.height / 2.0)
                redCircle.draw(in: CGRect(origin: circlePoint, size: redCircle.size))
                let numberPoint = CGPoint(
                    x: circlePoint.x - (numberStringSize.width / 2.0) + numberIconSize.width / 2.0,
                    y: circlePoint.y - (numberStringSize.height / 2.0) + numberIconSize.height / 2.0)
                numberString.draw(in: CGRect(origin: numberPoint, size: numberStringSize), withAttributes: attributes)
            }
            return newIcon
        }
        
        return cartIcon
    }
    
    // MARK: - Handlers
    
    @objc func cartButtonDidTap(_ sender: UIButton) {

        showSuggestions()
    }
    
}
