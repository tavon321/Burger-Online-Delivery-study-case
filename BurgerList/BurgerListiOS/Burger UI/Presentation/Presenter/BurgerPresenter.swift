//
//  BurgerPresenter.swift
//  BurgerListiOS
//
//  Created by Gustavo on 16/12/21.
//  Copyright © 2021 Gustavo Londono. All rights reserved.
//

import BurgerList

protocol LoadingBurgerView: AnyObject {
    func display(isLoading: Bool)
}

protocol BurgerView {
    func display(burgers: [Burger])
}

class BurgersPresenter {
    typealias Observer<T> = (T) -> Void
    private let burgerLoader: BurgerLoader
    
    var burgersView: BurgerView?
    weak var loadingBurgerView: LoadingBurgerView?
    
    init(burgerLoader: BurgerLoader) {
        self.burgerLoader = burgerLoader
    }
    
    func loadBurgers() {
        loadingBurgerView?.display(isLoading: true)
        burgerLoader.load { [weak self] result in
            if let burgers = try? result.get() {
                self?.burgersView?.display(burgers: burgers)
            }
            self?.loadingBurgerView?.display(isLoading: false)
        }
    }
}
