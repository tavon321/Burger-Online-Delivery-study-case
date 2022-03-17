//
//  BurgerViewAdapter.swift
//  BurgerListiOS
//
//  Created by Gustavo on 3/01/22.
//  Copyright © 2022 Gustavo Londono. All rights reserved.
//

import UIKit
import BurgerList

final class BurgerViewAdapter: BurgerView {
    private weak var controller: BurgerListController?
    private let imageLoader: BurgerImageLoader
    
    init(controller: BurgerListController, imageLoader: BurgerImageLoader) {
        self.controller = controller
        self.imageLoader = imageLoader
    }
    
    func display(_ viewModel: BurgerViewModel) {
        controller?.cellControllers = viewModel.burgers.map({ model in
            let burgerImagePresentationAdapter = BurgerImagePresentationAdapter<WeakRefVirtualProxy<BurgerCellController>, UIImage>(model: model, imageLoader: imageLoader)
            let cell = BurgerCellController(delegate: burgerImagePresentationAdapter)
            burgerImagePresentationAdapter.presenter = BurgerImagePresenter(view: WeakRefVirtualProxy(cell), imageTransformer: UIImage.init)
            
            return cell
        })
    }
}

extension WeakRefVirtualProxy: BurgerImageView where T: BurgerImageView, T.Image == UIImage {
    func display(_ model: BurgerImageViewModel<UIImage>) {
        object?.display(model)
    }
}
