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
    private let burgerLoader: BurgerLoader
    
    public var onChange: ((BurgersRefreshViewModel) -> Void)?
    public var onBurgerLoad: (([Burger]) -> Void)?
    
    private(set) var isLoading: Bool = false {
        didSet { onChange?(self) }
    }
    
    init(burgerLoader: BurgerLoader) {
        self.burgerLoader = burgerLoader
    }
    
    @objc func loadBurgers() {
        isLoading = true
        burgerLoader.load { [weak self] result in
            if let burgers = try? result.get() {
                self?.onBurgerLoad?(burgers)
            }
            
            self?.isLoading = false
        }
    }
}
