//
//  BurgersRefreshViewModel.swift
//  BurgerListiOS
//
//  Created by Gustavo on 23/11/21.
//  Copyright © 2021 Gustavo Londono. All rights reserved.
//

import Foundation
import BurgerList

class BurgersRefreshViewModel {
    typealias Observer<T> = (T) -> Void
    private let burgerLoader: BurgerLoader
    
    public var onLoadingStateChange: (Observer<Bool>)?
    public var onBurgerLoad: (Observer<[Burger]>)?
    
    init(burgerLoader: BurgerLoader) {
        self.burgerLoader = burgerLoader
    }
    
    @objc func loadBurgers() {
        onLoadingStateChange?(true)
        burgerLoader.load { [weak self] result in
            if let burgers = try? result.get() {
                self?.onBurgerLoad?(burgers)
            }
            
            self?.onLoadingStateChange?(false)
        }
    }
}
