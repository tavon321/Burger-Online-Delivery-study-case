//
//  BurgerImagePresenter.swift
//  BurgerList
//
//  Created by Gustavo on 29/03/22.
//  Copyright © 2022 Gustavo Londono. All rights reserved.
//

import Foundation

public protocol BurgerImageView {
    associatedtype Image
    
    func display(_ model: BurgerImageViewModel<Image>)
}

final public class BurgerImagePresenter<View: BurgerImageView, Image> where View.Image == Image {
    
    private let view: View
    private let imageTransformer: (Data) -> Image?
    
    private struct InvalidImageDataError: Error {}
    
    public init(view: View, imageTransformer: @escaping (Data) -> Image?) {
        self.view =  view
        self.imageTransformer = imageTransformer
    }
    
    public func cellDidLoad(for model: Burger) {
        view.display(BurgerImageViewModel(name: model.name,
                                          description: model.description,
                                          image: nil,
                                          isLoading: false,
                                          shouldRetry: false))
    }
    
    public func didStartLoadingImageData(for model: Burger) {
        view.display(BurgerImageViewModel(name: model.name,
                                          description: model.description,
                                          image: nil,
                                          isLoading: true,
                                          shouldRetry: false))
    }
    
    public func didFinishLoadingImageData(with data: Data, for model: Burger) {
        guard let image = imageTransformer(data) else {
            return didFinishLoadingImageData(with: InvalidImageDataError(), for: model)
        }
        
        view.display(BurgerImageViewModel(name: model.name,
                                          description: model.description,
                                          image: image,
                                          isLoading: false,
                                          shouldRetry: false))
    }
    
    public func didFinishLoadingImageData(with error: Error, for model: Burger) {
        view.display(BurgerImageViewModel(name: model.name,
                                          description: model.description,
                                          image: nil,
                                          isLoading: false,
                                          shouldRetry: true))
    }
}
