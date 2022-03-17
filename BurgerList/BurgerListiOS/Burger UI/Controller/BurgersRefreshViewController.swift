//
//  BurgersRefreshViewController.swift
//  BurgerListiOS
//
//  Created by Gustavo on 3/11/21.
//  Copyright © 2021 Gustavo Londono. All rights reserved.
//

import UIKit

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
        guard Thread.isMainThread else {
            return DispatchQueue.main.async { [weak self] in
                self?.display(viewModel)
            }
        }
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

// MVVM
//final class BurgersRefreshViewController: NSObject {
//    private(set) lazy var view: UIRefreshControl = {
//        return binded(UIRefreshControl())
//    }()
//
//    private let viewModel: BurgersRefreshViewModel
//
//    init(viewModel: BurgersRefreshViewModel) {
//        self.viewModel = viewModel
//    }
//
//    @objc func refresh() {
//        viewModel.loadBurgers()
//    }
//
//    private func binded(_ view: UIRefreshControl) -> UIRefreshControl {
//        viewModel.onLoadingStateChange = { [weak view] isLoading in
//            if isLoading {
//                view?.beginRefreshing()
//            } else {
//                view?.endRefreshing()
//            }
//        }
//        view.addTarget(self, action: #selector(refresh), for: .valueChanged)
//        return view
//    }
//}
