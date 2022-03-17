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
        
        let burgerController = BurgerListController.makeWith(refreshController: refreshController,
                                                                 title: BurgersPresenter.title)
        let presenter = BurgersPresenter(burgersView: BurgerViewAdapter(controller: burgerController,
                                                                        imageLoader: MainQueueDispatchDecorator(decoratee: imageLoader)),
                                         loadingBurgerView: WeakRefVirtualProxy(refreshController))
        presentationAdapter.presenter = presenter
         
        return burgerController
    }
}

private extension BurgerListController {
    static func makeWith(refreshController: BurgersRefreshViewController, title: String) -> BurgerListController {
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

//public final class BurgerUIComposer {
//    public static func compose(burgerLoader: BurgerLoader,
//                               imageLoader: BurgerImageLoader) -> BurgerListController {
//        let viewModel = BurgersRefreshViewModel(burgerLoader: burgerLoader)
//        let refreshController = BurgersRefreshViewController(viewModel: viewModel)
//        let burgerController = BurgerListController(refreshController: refreshController)
//        viewModel.onBurgerLoad = adaptToCellControllers(forwardingTo: burgerController,
//                                                        loader: imageLoader)
//
//        return burgerController
//    }
//
//    private static func adaptToCellControllers(forwardingTo controller: BurgerListController,
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

//private final class BurgerViewAdapter: BurgerView {
//    private weak var controller: BurgerListController?
//    private let imageLoader: BurgerImageLoader
//
//    init(controller: BurgerListController, imageLoader: BurgerImageLoader) {
//        self.controller = controller
//        self.imageLoader = imageLoader
//    }
//
//    func display(_ viewModel: BurgerViewModel) {
//        controller?.cellControllers = viewModel.burgers.map({ model in
//            let viewModel = BurgerImageViewModel(model: model,
//                                                 imageLoader: imageLoader,
//                                                 imageTransformer: UIImage.init(data:))
//            return BurgerCellController(viewModel: viewModel)
//        })
//    }
//}
