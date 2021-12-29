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
    
    var burgersView: BurgerView?
    var loadingBurgerView: LoadingBurgerView?
    
    func didStartLoadingBurgers() {
        loadingBurgerView?.display(.init(isLoading: true))
    }
    
    func didFinishLoadingBurgers(with burgers: [Burger]) {
        loadingBurgerView?.display(.init(isLoading: false))
        burgersView?.display(.init(burgers: burgers))
    }
    
    func didFinishLoadingBurgers(with error: Error) {
        loadingBurgerView?.display(.init(isLoading: false))
    }
}
