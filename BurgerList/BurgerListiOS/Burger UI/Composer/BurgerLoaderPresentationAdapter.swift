//
//  BurgerLoaderPresentationAdapter.swift
//  BurgerListiOS
//
//  Created by Gustavo on 3/01/22.
//  Copyright © 2022 Gustavo Londono. All rights reserved.
//

import UIKit
import BurgerList

public final class BurgerLoaderPresentationAdapter: BurgerListViewControllerDelegate {
    private let burgerLoader: BurgerLoader
    var presenter: BurgersPresenter?
    
    init(burgerLoader: BurgerLoader) {
        self.burgerLoader = burgerLoader
    }
    
    func loadBurgers() {
        presenter?.didStartLoadingBurgers()
        burgerLoader.load { [weak presenter] result in
            switch result {
            case .success(let burgers):
                presenter?.didFinishLoadingBurgers(with: burgers)
            case .failure(let error):
                presenter?.didFinishLoadingBurgers(with: error)
            }
        }
    }
}
