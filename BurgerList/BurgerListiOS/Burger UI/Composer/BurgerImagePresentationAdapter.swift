//
//  BurgerImagePresentationAdapter.swift
//  BurgerListiOS
//
//  Created by Gustavo on 16/03/22.
//  Copyright © 2022 Gustavo Londono. All rights reserved.
//

import Foundation
import BurgerList

final class BurgerImagePresentationAdapter<View: BurgerImageView, Image>: FeedImageCellControllerDelegate where View.Image == Image {
    private let model: Burger
    private let imageLoader: BurgerImageLoader
    
    var presenter: BurgerImagePresenter<View, Image>?
    
    private var task: HTTPClientTask?
    
    internal init(model: Burger, imageLoader: BurgerImageLoader) {
        self.model = model
        self.imageLoader = imageLoader
    }
    
    func didRequestImage() {
        self.presenter?.cellDidLoad(for: model)
        
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
            presenter?.didFinishLoadingImageData(with: error, for: model)
        }
    }
}
