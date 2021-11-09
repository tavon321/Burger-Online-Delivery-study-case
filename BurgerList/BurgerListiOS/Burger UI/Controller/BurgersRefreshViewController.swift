//
//  BurgersRefreshViewController.swift
//  BurgerListiOS
//
//  Created by Gustavo on 3/11/21.
//  Copyright © 2021 Gustavo Londono. All rights reserved.
//

import UIKit
import BurgerList

final class BurgersRefreshViewController: NSObject {
    private(set) lazy var view: UIRefreshControl = {
        let view = UIRefreshControl()
        view.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return view
    }()
    
    private let burgerLoader: BurgerLoader
    var onRefresh: (([Burger]) -> Void)?
    
    init(burgerLoader: BurgerLoader) {
        self.burgerLoader = burgerLoader
    }
    
    @objc func refresh() {
        view.beginRefreshing()
        
        burgerLoader.load { [weak self] result in
            if let burgers = try? result.get() {
                self?.onRefresh?(burgers)
            }
            self?.view.endRefreshing()
        }
    }
}
