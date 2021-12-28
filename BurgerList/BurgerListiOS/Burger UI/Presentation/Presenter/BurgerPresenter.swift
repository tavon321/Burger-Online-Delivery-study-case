//
//  BurgerPresenter.swift
//  BurgerListiOS
//
//  Created by Gustavo on 16/12/21.
//  Copyright © 2021 Gustavo Londono. All rights reserved.
//

import BurgerList

struct BurgerLoadingViewModel {
    var isLoading: Bool
}

protocol LoadingBurgerView: AnyObject {
    func display(_ viewModel: BurgerLoadingViewModel)
}

struct BurgerViewModel {
    var burgers: [Burger]
}

protocol BurgerView {
    func display(_ viewModel: BurgerViewModel)
}

class BurgersPresenter {
    typealias Observer<T> = (T) -> Void
    private let burgerLoader: BurgerLoader
    
    var burgersView: BurgerView?
    var loadingBurgerView: LoadingBurgerView?
    
    init(burgerLoader: BurgerLoader) {
        self.burgerLoader = burgerLoader
    }
    
    func loadBurgers() {
        loadingBurgerView?.display(.init(isLoading: true))
        burgerLoader.load { [weak self] result in
            if let burgers = try? result.get() {
                self?.burgersView?.display(.init(burgers: burgers))
            }
            self?.loadingBurgerView?.display(.init(isLoading: false))
        }
    }
}
