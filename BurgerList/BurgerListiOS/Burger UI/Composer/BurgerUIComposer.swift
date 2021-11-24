//
//  BurgerUIComposer.swift
//  BurgerListiOS
//
//  Created by Gustavo on 9/11/21.
//  Copyright © 2021 Gustavo Londono. All rights reserved.
//

import Foundation
import BurgerList

public final class BurgerUIComposer {
    public static func compose(burgerLoader: BurgerLoader,
                               imageLoader: BurgerImageLoader) -> BurgerListViewController {
        let viewModel = BurgersRefreshViewModel(burgerLoader: burgerLoader)
        let refreshController = BurgersRefreshViewController(viewModel: viewModel)
        let burgerController = BurgerListViewController(refreshController: refreshController)
        viewModel.onBurgerLoad = adaptToCellControllers(forwardingTo: burgerController,
                                                        loader: imageLoader)
        
        return burgerController
    }
    
    private static func adaptToCellControllers(forwardingTo controller: BurgerListViewController,
                                               loader: BurgerImageLoader)
    -> ([Burger]) -> Void {
        return { [weak controller] burgers in
            controller?.cellControllers = burgers.map({ model in
                let viewModel = BurgerImageViewModel(model: model, imageLoader: loader)
                return BurgerCellController(viewModel: viewModel)
            })
        }
    }
}
