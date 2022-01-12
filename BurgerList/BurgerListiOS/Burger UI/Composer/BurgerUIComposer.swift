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
                               imageLoader: BurgerImageLoader) -> BurgerListViewController {
        let presentationAdapter = BurgerLoaderPresentationAdapter(burgerLoader: burgerLoader)
        let refreshController = BurgersRefreshViewController(delegate: presentationAdapter)
        
        let bundle = Bundle(for: BurgerListViewController.self)
        let storyboad = UIStoryboard(name: "Burgers", bundle: bundle)
        let burgerController = storyboad.instantiateInitialViewController() as! BurgerListViewController
        burgerController.refreshController = refreshController
        
        let presenter = BurgersPresenter(burgersView: BurgerViewAdapter(controller: burgerController, imageLoader: imageLoader),
                                         loadingBurgerView: WeakRefVirtualProxy(refreshController))
        presentationAdapter.presenter = presenter
         
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

//private final class BurgerViewAdapter: BurgerView {
//    private weak var controller: BurgerListViewController?
//    private let imageLoader: BurgerImageLoader
//
//    init(controller: BurgerListViewController, imageLoader: BurgerImageLoader) {
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
