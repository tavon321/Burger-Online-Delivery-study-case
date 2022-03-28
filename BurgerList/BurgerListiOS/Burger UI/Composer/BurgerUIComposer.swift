//
//  BurgerUIComposer.swift
//  BurgerListiOS
//
//  Created by Gustavo on 9/11/21.
//  Copyright © 2021 Gustavo Londono. All rights reserved.
//

import BurgerList
import UIKit

public final class BurgerUIComposer {
    public static func compose(burgerLoader: BurgerLoader,
                               imageLoader: BurgerImageLoader) -> BurgerListController {
        let presentationAdapter = BurgerLoaderPresentationAdapter(burgerLoader:
            MainQueueDispatchDecorator(decoratee: burgerLoader)
        )
        let refreshController = BurgersRefreshViewController(delegate: presentationAdapter)
        let burgerController = makeBurgerListController(refreshController: refreshController,
                                                                 title: BurgersPresenter.title)
        let presenter = BurgersPresenter(burgersView: BurgerViewAdapter(controller: burgerController,
                                                                        imageLoader: MainQueueDispatchDecorator(decoratee: imageLoader)),
                                         errorView: WeakRefVirtualProxy(burgerController),
                                         loadingBurgerView: WeakRefVirtualProxy(refreshController))
        presentationAdapter.presenter = presenter
         
        return burgerController
    }
    
    private static func makeBurgerListController(refreshController: BurgersRefreshViewController, title: String) -> BurgerListController {
        let bundle = Bundle(for: BurgerListController.self)
        let storyboad = UIStoryboard(name: "Burgers", bundle: bundle)
        
        let burgerController = storyboad.instantiateInitialViewController { coder in
            return BurgerListController(coder: coder, refreshController: refreshController)
        }!
        burgerController.title = BurgersPresenter.title
        return burgerController
    }
}

extension WeakRefVirtualProxy: LoadingBurgerView where T: LoadingBurgerView {
    func display(_ viewModel: BurgerLoadingViewModel) {
        object?.display(viewModel)
    }
}

extension WeakRefVirtualProxy: BurgerErrorView where T: BurgerErrorView {
    func display(_ viewModel: BurgerErrorViewModel) {
        object?.display(viewModel)
    }
}
