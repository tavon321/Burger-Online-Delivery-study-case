//
//  BurgersPresenter.swift
//  BurgerListiOS
//
//  Created by Gustavo on 16/12/21.
//  Copyright © 2021 Gustavo Londono. All rights reserved.
//

import BurgerList
import Foundation

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

public final class BurgersPresenter {
    private let burgersView: BurgerView
    private let loadingBurgerView: LoadingBurgerView
    
    static var title: String {
        NSLocalizedString("BURGERLIST_VIEW_TITLE",
                          tableName: "Burgers",
                          bundle: Bundle(for: BurgersPresenter.self),
                          comment: "Title for the burger lists")
    }
    
    init(burgersView: BurgerView, loadingBurgerView: LoadingBurgerView) {
        self.burgersView = burgersView
        self.loadingBurgerView = loadingBurgerView
    }
    
    func didStartLoadingBurgers() {
        loadingBurgerView.display(.init(isLoading: true))
    }
    
    func didFinishLoadingBurgers(with burgers: [Burger]) {
        loadingBurgerView.display(.init(isLoading: false))
        burgersView.display(.init(burgers: burgers))
    }
    
    func didFinishLoadingBurgers(with error: Error) {
        loadingBurgerView.display(.init(isLoading: false))
    }
}
