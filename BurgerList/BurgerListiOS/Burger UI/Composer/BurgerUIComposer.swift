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
        let presentationAdapter = BurgerLoaderPresentationAdapter(burgerLoader: burgerLoader)
        let refreshController = BurgersRefreshViewController(delegate: presentationAdapter)
        let burgerController = BurgerListViewController(refreshController: refreshController)
        let presenter = BurgersPresenter(burgersView: BurgerViewAdapter(controller: burgerController, imageLoader: imageLoader),
                                         loadingBurgerView: WeakRefVirtualProxy(refreshController))
        presentationAdapter.presenter = presenter
         
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
    
    func display(_ viewModel: BurgerViewModel) {
        controller?.cellControllers = viewModel.burgers.map({ model in
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
    func display(_ viewModel: BurgerLoadingViewModel) {
        object?.display(viewModel)
    }
}

public final class BurgerLoaderPresentationAdapter: BurgerListViewControllerDelegate {
    private let burgerLoader: BurgerLoader
    var presenter: BurgersPresenter?
    
    init(burgerLoader: BurgerLoader) {
        self.burgerLoader = burgerLoader
    }
    
    func loadBurgers() {
        presenter?.didStartLoadingBurgers()
        burgerLoader.load { [weak presenter] result in
            switch result {
            case .success(let burgers):
                presenter?.didFinishLoadingBurgers(with: burgers)
            case .failure(let error):
                presenter?.didFinishLoadingBurgers(with: error)
            }
        }
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
