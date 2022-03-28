//
//  BurgersRefreshViewController.swift
//  BurgerListiOS
//
//  Created by Gustavo on 3/11/21.
//  Copyright © 2021 Gustavo Londono. All rights reserved.
//

import UIKit
import BurgerList

protocol BurgerListControllerDelegate {
    func loadBurgers()
}

final class BurgersRefreshViewController: NSObject, LoadingBurgerView {
    
    private(set) lazy var view: UIRefreshControl = loadView()
    
    private let delegate: BurgerListControllerDelegate
    
    init(delegate: BurgerListControllerDelegate) {
        self.delegate = delegate
    }
    
    @objc func refresh() {
        delegate.loadBurgers()
    }
    
    func display(_ viewModel: BurgerLoadingViewModel) {
        if viewModel.isLoading {
            view.beginRefreshing()
        } else {
            view.endRefreshing()
        }
    }
    
    private func loadView() -> UIRefreshControl {
        let view = UIRefreshControl()
        view.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return view
    }
}
