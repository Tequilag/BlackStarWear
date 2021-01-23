//
//  BSWTableView.swift
//  BlackStarWear
//
//  Created by Georgy Gorbenko on 18.12.2020.
//

import UIKit

class BSWTableView: UITableView {
    
    var isRefreshing: Bool = false {
        
        didSet {
            
            if isRefreshing {
                
                refreshControl?.beginRefreshing()
            }
            else {
                
                refreshControl?.endRefreshing()
            }
        }
    }
    
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        
        guard window != nil else { return }
        super.layoutSubviews()
    }
    
}

// MARK: - Private methods
private extension BSWTableView {
    
    func setupUI() {
        
        tableFooterView = UIView()
        separatorColor = AppDesign.Color.separator.ui
    }
    
}
