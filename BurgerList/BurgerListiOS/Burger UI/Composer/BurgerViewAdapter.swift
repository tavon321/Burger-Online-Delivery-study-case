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
    private weak var controller: BurgerListViewController?
    private let imageLoader: BurgerImageLoader
    
    init(controller: BurgerListViewController, imageLoader: BurgerImageLoader) {
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

final class BurgerImagePresentationAdapter<View: BurgerImageView, Image>: FeedImageCellControllerDelegate where View.Image == Image {
    private let model: Burger
    private let imageLoader: BurgerImageLoader
    
    var presenter: BurgerImagePresenter<View, Image>?
    
    private var task: BurgerImageDataLoadTask?
    
    internal init(model: Burger, imageLoader: BurgerImageLoader) {
        self.model = model
        self.imageLoader = imageLoader
    }
    
    func didRequestImage() {
        presenter?.didInit(for: model)
        
        guard let url = model.imageURL else { return }
        
        presenter?.didStartLoadingImageData(for: model)
        
        task = imageLoader.loadImageData(from: url) { [weak self] result in
            self?.handle(result)
        }
    }
    
    func didCancelImageRequest() {
        task?.cancel()
    }
    
    private func handle(_ result: BurgerImageLoader.Result) {
        switch result {
        case .success(let imageData):
            presenter?.didFinishLoadingImageData(with: imageData, for: model)
        case .failure(let error):
            presenter?.didFinishLoadingImageData(with: error, for: model    )
        }
    }
}
