//
//  BurgerCellController.swift
//  BurgerListiOS
//
//  Created by Gustavo on 9/11/21.
//  Copyright © 2021 Gustavo Londono. All rights reserved.
//

import UIKit
import BurgerList

final class BurgerCellController {
    private var task:  BurgerImageDataLoadTask?
    private let model: Burger
    private let imageLoader: BurgerImageLoader
    
    init(model: Burger, imageLoader: BurgerImageLoader) {
        self.model = model
        self.imageLoader =  imageLoader
    }
    
    func view() -> UITableViewCell {
        let cell = BurgerCell()
        
        cell.nameLabel.text = model.name
        cell.descriptionLabel.text = model.description
        cell.descriptionLabel.isHidden = model.description == nil
        cell.burgerImageView.image = nil
        cell.burgerImageRetryButton.isHidden = true
        cell.imageContainer.startShimmering()
        
        let loadImage = { [weak self] in
            guard let self = self, let url = self.model.imageURL else { return }
            self.task = self.imageLoader.loadImageData(from: url) { [weak self] result in
                    guard self != nil else { return }
                    switch result {
                    case .success(let imageData):
                        let image = UIImage(data: imageData)
                        
                        cell.burgerImageView.image = image
                        cell.burgerImageRetryButton.isHidden = image != nil
                    case .failure:
                        cell.burgerImageRetryButton.isHidden = false
                    }
                    cell.imageContainer.stopShimmering()
                }
        }
        
        loadImage()
        cell.onRetry = loadImage
        
        return cell
    }
    
    func preload() {
        guard let url = self.model.imageURL else { return }
        self.task = self.imageLoader.loadImageData(from: url) { _ in }
    }
    
    func cancelLoad() {
        task?.cancel()
    }
}
