//
//  BurgersRefreshViewController.swift
//  BurgerListiOS
//
//  Created by Gustavo on 3/11/21.
//  Copyright © 2021 Gustavo Londono. All rights reserved.
//

import UIKit

final class BurgersRefreshViewController: NSObject {
    private(set) lazy var view: UIRefreshControl = {
        return binded(UIRefreshControl())
    }()
    
    private let viewModel: BurgersRefreshViewModel
    
    init(viewModel: BurgersRefreshViewModel) {
        self.viewModel = viewModel
    }
    
    @objc func refresh() {
        viewModel.loadBurgers()
    }
    
    private func binded(_ view: UIRefreshControl) -> UIRefreshControl {
        viewModel.onChange = { [weak self] receivedViewModel in
            if receivedViewModel.isLoading {
                self?.view.beginRefreshing()
            } else {
                self?.view.endRefreshing()
            }
        }
        view.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return view
    }
}
