//
//  ViewModelControllerExample.swift
//  BurgerListiOS
//
//  Created by Gustavo on 28/03/22.
//  Copyright © 2022 Gustavo Londono. All rights reserved.
//

import Foundation

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
