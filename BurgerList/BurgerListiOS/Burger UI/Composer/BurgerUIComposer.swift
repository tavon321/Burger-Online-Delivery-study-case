//
//  BurgerUIComposer.swift
//  BurgerListiOS
//
//  Created by Gustavo on 9/11/21.
//  Copyright © 2021 Gustavo Londono. All rights reserved.
//

import Foundation
import BurgerList
import UIKit

public final class BurgerUIComposer {
    public static func compose(burgerLoader: BurgerLoader,
                               imageLoader: BurgerImageLoader) -> BurgerListViewController {
        let presenter = BurgersPresenter(burgerLoader: burgerLoader)
        let refreshController = BurgersRefreshViewController(presenter: presenter)
        let burgerController = BurgerListViewController(refreshController: refreshController)
        
        presenter.loadingBurgerView = WeakRefVirtualProxy(refreshController)
        presenter.burgersView = BurgerViewAdapter(controller: burgerController, imageLoader: imageLoader)
        
        return burgerController
    }
}

private final class BurgerViewAdapter: BurgerView {
    private weak var controller: BurgerListViewController?
    private let imageLoader: BurgerImageLoader
    
    init(controller: BurgerListViewController, imageLoader: BurgerImageLoader) {
        self.controller = controller
        self.imageLoader = imageLoader
    }
    
    func display(burgers: [Burger]) {
        controller?.cellControllers = burgers.map({ model in
            let viewModel = BurgerImageViewModel(model: model,
                                                 imageLoader: imageLoader,
                                                 imageTransformer: UIImage.init(data:))
            return BurgerCellController(viewModel: viewModel)
        })
    }
}

private final class WeakRefVirtualProxy<T: AnyObject> {
    private weak var object: T?
    
    init(_ object: T) {
        self.object = object
    }
}

extension WeakRefVirtualProxy: LoadingBurgerView where T: LoadingBurgerView {
    func display(isLoading: Bool) {
        object?.display(isLoading: isLoading)
    }
}

//public final class BurgerUIComposer {
//    public static func compose(burgerLoader: BurgerLoader,
//                               imageLoader: BurgerImageLoader) -> BurgerListViewController {
//        let viewModel = BurgersRefreshViewModel(burgerLoader: burgerLoader)
//        let refreshController = BurgersRefreshViewController(viewModel: viewModel)
//        let burgerController = BurgerListViewController(refreshController: refreshController)
//        viewModel.onBurgerLoad = adaptToCellControllers(forwardingTo: burgerController,
//                                                        loader: imageLoader)
//
//        return burgerController
//    }
//
//    private static func adaptToCellControllers(forwardingTo controller: BurgerListViewController,
//                                               loader: BurgerImageLoader)
//    -> ([Burger]) -> Void {
//        return { [weak controller] burgers in
//            controller?.cellControllers = burgers.map({ model in
//                let viewModel = BurgerImageViewModel(model: model,
//                                                     imageLoader: loader,
//                                                     imageTransformer: UIImage.init(data:))
//                return BurgerCellController(viewModel: viewModel)
//            })
//        }
//    }
//}
