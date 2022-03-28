//
//  ViewModelExample.swift
//  BurgerListiOS
//
//  Created by Gustavo on 28/03/22.
//  Copyright © 2022 Gustavo Londono. All rights reserved.
//

import Foundation

//final class BurgerImageViewModel<Image> {
//    typealias Observer<T> = (T) -> Void
//
//    private var task: BurgerImageDataLoadTask?
//    private let model: Burger
//    private let imageLoader: BurgerImageLoader
//    private let imageTransformer: (Data) -> Image?
//
//    init(model: Burger,
//         imageLoader: BurgerImageLoader,
//         imageTransformer: @escaping (Data) -> Image?) {
//        self.model = model
//        self.imageLoader = imageLoader
//        self.imageTransformer = imageTransformer
//    }
//
//    var name: String {
//        return model.name
//    }
//
//    var description: String? {
//        return model.description
//    }
//
//    var hasDescription: Bool {
//        return model.description != nil
//    }
//
//    var onImageLoad: Observer<Image>?
//    var onImageLoadingStateChange: Observer<Bool>?
//    var onShouldRetryImageLoadStateChange: Observer<Bool>?
//
//    func loadImageData() {
//        onImageLoadingStateChange?(true)
//        onShouldRetryImageLoadStateChange?(false)
//
//        guard let url = model.imageURL else { return }
//        task = imageLoader.loadImageData(from: url) { [weak self] result in
//            self?.handle(result)
//        }
//    }
//
//    private func handle(_ result: BurgerImageLoader.Result) {
//        switch result {
//        case .success(let imageData):
//            if let image = imageTransformer(imageData) {
//                onImageLoad?(image)
//            } else {
//                onShouldRetryImageLoadStateChange?(true)
//            }
//        case .failure:
//            onShouldRetryImageLoadStateChange?(true)
//        }
//        onImageLoadingStateChange?(false)
//    }
//
//    func cancelImageDataLoad() {
//        task?.cancel()
//        task = nil
//    }
//}
