//
//  BurgerImagePresenter.swift
//  BurgerListiOS
//
//  Created by Gustavo on 3/01/22.
//  Copyright © 2022 Gustavo Londono. All rights reserved.
//

import Foundation
import BurgerList

protocol BurgerImageView {
    associatedtype Image
    
    func display(_ model: BurgerImageViewModel<Image>)
}

final class BurgerImagePresenter<View: BurgerImageView, Image> where View.Image == Image {

    private let view: View
    private let imageTransformer: (Data) -> Image?
    
    internal init(view: View, imageTransformer: @escaping (Data) -> Image?) {
        self.view = view
        self.imageTransformer = imageTransformer
    }
    
    func didInit(for model: Burger) {
        view.display(BurgerImageViewModel(name: model.name,
                                          description: model.description,
                                          image: nil,
                                          isLoading: false,
                                          shouldRetry: false))
    }
    
    func didStartLoadingImageData(for model: Burger) {
        view.display(BurgerImageViewModel(name: model.name,
                                          description: model.description,
                                          image: nil,
                                          isLoading: true,
                                          shouldRetry: false))
    }
    
    private struct InvalidImageDataError: Error {}
    
    func didFinishLoadingImageData(with data: Data, for model: Burger) {
        guard let image = imageTransformer(data) else {
            return didFinishLoadingImageData(with: InvalidImageDataError(), for: model)
        }
        
        view.display(BurgerImageViewModel(name: model.name,
                                          description: model.description,
                                          image: image,
                                          isLoading: false,
                                          shouldRetry: false))
    }
    
    func didFinishLoadingImageData(with error: Error, for model: Burger) {
        view.display(BurgerImageViewModel(name: model.name,
                                          description: model.description,
                                          image: nil,
                                          isLoading: false,
                                          shouldRetry: true))
    }
}

