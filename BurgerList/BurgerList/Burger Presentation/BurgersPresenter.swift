//
//  BurgersPresenter.swift
//  BurgerList
//
//  Created by Gustavo on 28/03/22.
//  Copyright © 2022 Gustavo Londono. All rights reserved.
//

import Foundation

public protocol BurgerErrorView {
    func display(_ viewModel: BurgerErrorViewModel)
}

public protocol LoadingBurgerView: AnyObject {
    func display(_ viewModel: BurgerLoadingViewModel)
}

public protocol BurgerView {
    func display(_ viewModel: BurgerViewModel)
}

public final class BurgersPresenter {
    private let burgersView: BurgerView
    private let errorView: BurgerErrorView
    private let loadingBurgerView: LoadingBurgerView
    
    public static var title: String {
        NSLocalizedString("BURGERLIST_VIEW_TITLE",
                          tableName: "Burgers",
                          bundle: Bundle(for: BurgersPresenter.self),
                          comment: "Title for the burger lists")
    }
    
    private var burgerLoadErrorMessage: String {
        NSLocalizedString("BURGER_VIEW_CONNECTION_ERROR",
                          tableName: "Burgers",
                          bundle: Bundle(for: BurgersPresenter.self),
                          comment: "Error message displayer when we can't load the burgers from the server ")
    }
    
    public init(burgersView: BurgerView, errorView: BurgerErrorView, loadingBurgerView: LoadingBurgerView) {
        self.burgersView = burgersView
        self.errorView = errorView
        self.loadingBurgerView = loadingBurgerView
    }
    
    public func didStartLoadingBurgers() {
        loadingBurgerView.display(.init(isLoading: true))
        errorView.display(.noError)
    }
    
    public func didFinishLoadingBurgers(with burgers: [Burger]) {
        loadingBurgerView.display(.init(isLoading: false))
        burgersView.display(.init(burgers: burgers))
    }
    
    public func didFinishLoadingBurgers(with error: Error) {
        loadingBurgerView.display(.init(isLoading: false))
        errorView.display(.error(message: burgerLoadErrorMessage))
    }
}
