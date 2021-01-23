//
//  ScrollablePageControl.swift
//  BlackStarWear
//
//  Created by Georgy Gorbenko on 22.12.2020.
//

import UIKit

class ScrollablePageControl: UIView {
    
    // MARK: - Public properties
    
    var animateDuration: TimeInterval = 0.3
    private(set) var currentPage: Int = 0
    
    var numberOfPages: Int = 0 {
        
        didSet {
            
            scrollView.isHidden = (numberOfPages <= 1 && hidesForSinglePage)
            displayCount = min(config.displayCount, numberOfPages)
            update(currentPage: currentPage, config: config)
        }
    }
    
    var pageIndicatorTintColor = UIColor.black.with(alpha: 0.8) {
        
        didSet {
            
            updateDotColor(currentPage: currentPage)
        }
    }
    
    var currentPageIndicatorTintColor = AppDesign.Color.info.ui.with(alpha: 0.8) {
        
        didSet {
            
            updateDotColor(currentPage: currentPage)
        }
    }
    
    var hidesForSinglePage: Bool = true {
        
        didSet {
            
            scrollView.isHidden = (numberOfPages <= 1 && hidesForSinglePage)
        }
    }
    
    override var intrinsicContentSize: CGSize {
        
        return CGSize(width: itemSize * CGFloat(displayCount), height: itemSize)
    }
    
    // MARK: - Private properties
    
    private let scrollView = UIScrollView()
    
    private var items: [ItemView] = []
    private var config = Config()
    
    private var itemSize: CGFloat {
        
        return config.dotSize + config.dotSpace
    }
    
    private var displayCount: Int = 0 {
        
        didSet {
            
            invalidateIntrinsicContentSize()
        }
    }
    
    // MARK: - Lifecycle
    
    init() {
        super.init(frame: .zero)
        
        setupUI()
        updateViewSize()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setupUI()
        updateViewSize()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        scrollView.center = CGPoint(x: bounds.width / 2, y: bounds.height / 2)
    }
    
}

// MARK: - Public methods
extension ScrollablePageControl {
    
    func setConfig(_ config: Config) {
        
        self.config = config
        invalidateIntrinsicContentSize()
        update(currentPage: currentPage, config: config)
    }
    
    func setCurrentPage(at currentPage: Int, animated: Bool = false) {
        
        guard 0...numberOfPages ~= currentPage, currentPage != self.currentPage else { return }
        
        scrollView.layer.removeAllAnimations()
        updateDot(at: currentPage, animated: animated)
        self.currentPage = currentPage
    }
    
    func setProgress(contentOffsetX: CGFloat, pageWidth: CGFloat) {
        
        guard pageWidth > 0 else { return }
        let currentPage = Int(round(contentOffsetX / pageWidth))
        setCurrentPage(at: currentPage, animated: true)
    }
    
}

// MARK: - Public type definitions
extension ScrollablePageControl {
    
    enum State {
        
        case none
        case small
        case medium
        case normal
    }
    
    struct Config {
        
        var displayCount: Int
        var dotSize: CGFloat
        var dotSpace: CGFloat
        var smallDotSizeRatio: CGFloat
        var mediumDotSizeRatio: CGFloat
        
        init(displayCount: Int = 7,
             dotSize: CGFloat = 6.0,
             dotSpace: CGFloat = 4.0,
             smallDotSizeRatio: CGFloat = 1,
             mediumDotSizeRatio: CGFloat = 1) {
            
            self.displayCount = displayCount
            self.dotSize = dotSize
            self.dotSpace = dotSpace
            self.smallDotSizeRatio = smallDotSizeRatio
            self.mediumDotSizeRatio = mediumDotSizeRatio
        }
    }
    
}

// MARK: - Private type definitions
private extension ScrollablePageControl {
    
    enum Direction {
        
        case left
        case right
        case stay
    }
    
    struct ItemConfig {
        
        var dotSize: CGFloat
        var itemSize: CGFloat
        var smallDotSizeRatio: CGFloat
        var mediumDotSizeRatio: CGFloat
    }
    
    class ItemView: UIView {
        
        // MARK: - Public properties
        
        var index: Int
        var animateDuration: TimeInterval = 0.3
        
        var dotColor = UIColor.lightGray {
            
            didSet {
                
                dotView.backgroundColor = dotColor
            }
        }
        
        var state: State = .normal {
            
            didSet {
                
                updateDotSize(state: state)
            }
        }
        
        // MARK: - Private properties
        
        private let dotView = UIView()
        private let itemSize: CGFloat
        private let dotSize: CGFloat
        private let mediumSizeRatio: CGFloat
        private let smallSizeRatio: CGFloat
        
        // MARK: - Lifecycle
        
        init(config: ItemConfig, index: Int) {
            
            self.itemSize = config.itemSize
            self.dotSize = config.dotSize
            self.mediumSizeRatio = config.mediumDotSizeRatio
            self.smallSizeRatio = config.smallDotSizeRatio
            self.index = index
            
            let xOffset = itemSize * CGFloat(index)
            let frame = CGRect(x: xOffset, y: 0, width: itemSize, height: itemSize)
            
            super.init(frame: frame)
            
            backgroundColor = UIColor.clear
            
            dotView.frame.size = CGSize(width: dotSize, height: dotSize)
            dotView.center = CGPoint(x: itemSize/2, y: itemSize/2)
            dotView.backgroundColor = dotColor
            dotView.layer.cornerRadius = dotSize/2
            dotView.layer.masksToBounds = true
            
            addSubview(dotView)
        }
        
        required init?(coder aDecoder: NSCoder) {
            
            fatalError("init(coder:) has not been implemented")
        }
        
        // MARK: - Private methods
        
        private func updateDotSize(state: State) {
            
            var newSize: CGSize
            
            switch state {
            case .normal:
                newSize = CGSize(width: dotSize, height: dotSize)
            case .medium:
                newSize = CGSize(width: dotSize * mediumSizeRatio, height: dotSize * mediumSizeRatio)
            case .small:
                newSize = CGSize( width: dotSize * smallSizeRatio, height: dotSize * smallSizeRatio)
            case .none:
                newSize = CGSize.zero
            }
            
            UIView.animate(withDuration: animateDuration, animations: { [weak self] in
                
                self?.dotView.layer.cornerRadius = newSize.height / 2.0
                self?.dotView.layer.bounds.size = newSize
            })
        }
    }
    
}

// MARK: - Private methods
private extension ScrollablePageControl {
    
    func setupUI() {
        
        backgroundColor = .clear
        
        scrollView.backgroundColor = .clear
        scrollView.isUserInteractionEnabled = false
        scrollView.showsHorizontalScrollIndicator = false
        
        addSubview(scrollView)
    }
    
    func updateDot(at currentPage: Int, animated: Bool) {
        
        updateDotColor(currentPage: currentPage)
        
        if numberOfPages > displayCount {
            
            updateDotPosition(currentPage: currentPage, animated: animated)
            updateDotSize(currentPage: currentPage, animated: animated)
        }
    }
    
    func updateDotColor(currentPage: Int) {
        
        items.forEach {
            
            $0.dotColor = ($0.index == currentPage)
                ? currentPageIndicatorTintColor
                : pageIndicatorTintColor
        }
    }
    
    func updateDotPosition(currentPage: Int, animated: Bool) {
        
        let duration = animated ? animateDuration : 0
        
        if currentPage == 0 {
            
            let xOffset = -scrollView.contentInset.left
            moveScrollView(xOffset: xOffset, duration: duration)
        }
        else if currentPage == numberOfPages - 1 {
            
            let xOffset = scrollView.contentSize.width - scrollView.bounds.width + scrollView.contentInset.right
            moveScrollView(xOffset: xOffset, duration: duration)
        }
        else if CGFloat(currentPage) * itemSize <= scrollView.contentOffset.x + itemSize {
            
            let xOffset = scrollView.contentOffset.x - itemSize
            moveScrollView(xOffset: xOffset, duration: duration)
        }
        else if CGFloat(currentPage) * itemSize + itemSize >=
            scrollView.contentOffset.x + scrollView.bounds.width - itemSize {
            
            let xOffset = scrollView.contentOffset.x + itemSize
            moveScrollView(xOffset: xOffset, duration: duration)
        }
    }
    
    func updateDotSize(currentPage: Int, animated: Bool) {
        
        let duration = animated ? animateDuration : 0
        
        items.forEach { item in
            
            item.animateDuration = duration
            if item.index == currentPage {
                
                item.state = .normal
            }
            else if item.index < 0 { // outside of left
                
                item.state = .none
            }
            else if item.index > numberOfPages - 1 { // outside of right
                
                item.state = .none
            }
            else if item.frame.minX <= scrollView.contentOffset.x { // first dot from left
                
                item.state = .small
            }
            else if item.frame.maxX >= scrollView.contentOffset.x + scrollView.bounds.width { // first dot from right
                
                item.state = .small
            }
            else if item.frame.minX <= scrollView.contentOffset.x + itemSize { // second dot from left
                
                item.state = .medium
            }
            else if item.frame.maxX
                >= scrollView.contentOffset.x + scrollView.bounds.width - itemSize { // second dot from right
                
                item.state = .medium
            }
            else {
                
                item.state = .normal
            }
        }
    }
    
    func moveScrollView(xOffset: CGFloat, duration: TimeInterval) {
        
        let direction = behaviorDirection(xOffset: xOffset)
        reusedView(direction: direction)
        UIView.animate(withDuration: duration, animations: { [weak self] in
            
            self?.scrollView.contentOffset.x = xOffset
        })
    }
    
    func behaviorDirection(xOffset: CGFloat) -> Direction {
        
        switch xOffset {
        case let xOffset where xOffset > scrollView.contentOffset.x:
            return .right
        case let xOffset where xOffset < scrollView.contentOffset.x:
            return .left
        default:
            return .stay
        }
    }
    
    func reusedView(direction: Direction) {
        
        guard let firstItem = items.first, let lastItem = items.last else { return }
        
        switch direction {
        case .left:
            lastItem.index = firstItem.index - 1
            lastItem.frame = CGRect(x: CGFloat(lastItem.index) * itemSize, y: 0, width: itemSize, height: itemSize)
            items.insert(lastItem, at: 0)
            items.removeLast()
        case .right:
            firstItem.index = lastItem.index + 1
            firstItem.frame = CGRect(x: CGFloat(firstItem.index) * itemSize, y: 0, width: itemSize, height: itemSize)
            items.insert(firstItem, at: items.count)
            items.removeFirst()
        case .stay:
            break
        }
    }
    
    func update(currentPage: Int, config: Config) {
        
        let itemConfig = ItemConfig(dotSize: config.dotSize,
                                    itemSize: itemSize,
                                    smallDotSizeRatio: config.smallDotSizeRatio,
                                    mediumDotSizeRatio: config.mediumDotSizeRatio)
        
        if currentPage < displayCount {
            
            items = (-2..<(displayCount + 2)).map { ItemView(config: itemConfig, index: $0) }
        }
        else {
            
            guard let firstItem = items.first, let lastItem = items.last else { return }
            items = (firstItem.index...lastItem.index).map { ItemView(config: itemConfig, index: $0) }
        }
        
        scrollView.contentSize = .init(width: itemSize * CGFloat(numberOfPages), height: itemSize)
        
        scrollView.subviews.forEach { $0.removeFromSuperview() }
        items.forEach { scrollView.addSubview($0) }
        
        let size: CGSize = .init(width: itemSize * CGFloat(displayCount), height: itemSize)
        
        scrollView.bounds.size = size
        
        if displayCount < numberOfPages {
            
            scrollView.contentInset = .init(top: 0, left: itemSize * 2, bottom: 0, right: itemSize * 2)
        }
        else {
            
            scrollView.contentInset = .init(top: 0, left: 0, bottom: 0, right: 0)
        }
        
        updateDot(at: currentPage, animated: false)
    }
    
    func updateViewSize() {
        
        bounds.size = intrinsicContentSize
    }
    
}
