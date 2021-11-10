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
        let refreshController = BurgersRefreshViewController(burgerLoader: burgerLoader)
        let burgerController = BurgerListViewController(refreshController: refreshController)
        refreshController.onRefresh = { [weak burgerController] burgers in
            burgerController?.cellControllers = burgers.map({ model in
                BurgerCellController(model: model, imageLoader: imageLoader)
            })
        }
        
        return burgerController
    }
}
