//
//  BurgerImageViewModel.swift
//  BurgerListiOS
//
//  Created by Gustavo on 24/11/21.
//  Copyright © 2021 Gustavo Londono. All rights reserved.
//

import UIKit
import BurgerList

final class BurgerImageViewModel {
    typealias Observer<T> = (T) -> Void

    private var task: BurgerImageDataLoadTask?
    private let model: Burger
    private let imageLoader: BurgerImageLoader

    init(model: Burger, imageLoader: BurgerImageLoader) {
        self.model = model
        self.imageLoader = imageLoader
    }
    
    var name: String {
        return model.name
    }

    var description: String? {
        return model.description
    }
    
    var hasDescription: Bool {
        return model.description != nil
    }

    var onImageLoad: Observer<UIImage>?
    var onImageLoadingStateChange: Observer<Bool>?
    var onShouldRetryImageLoadStateChange: Observer<Bool>?

    func loadImageData() {
        onImageLoadingStateChange?(true)
        onShouldRetryImageLoadStateChange?(false)
        
        guard let url = model.imageURL else { return }
        task = imageLoader.loadImageData(from: url) { [weak self] result in
            self?.handle(result)
        }
    }

    private func handle(_ result: BurgerImageLoader.Result) {
        switch result {
        case .success(let imageData):
            if let image = UIImage(data: imageData) {
                onImageLoad?(image)
            }
        case .failure:
            onShouldRetryImageLoadStateChange?(true)
        }
        onImageLoadingStateChange?(false)
    }

    func cancelImageDataLoad() {
        task?.cancel()
        task = nil
    }
}
