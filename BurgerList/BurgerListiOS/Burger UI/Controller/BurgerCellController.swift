//
//  BurgerCellController.swift
//  BurgerListiOS
//
//  Created by Gustavo on 9/11/21.
//  Copyright © 2021 Gustavo Londono. All rights reserved.
//

import UIKit
import BurgerList

protocol FeedImageCellControllerDelegate {
    func didRequestImage()
    func didCancelImageRequest()
}

final class BurgerCellController: BurgerImageView {
    
    private let delegate: FeedImageCellControllerDelegate
    private var cell: BurgerCell?
    
    init(delegate: FeedImageCellControllerDelegate) {
        self.delegate = delegate
    }
    
    func view(tableView: UITableView, for indexPath: IndexPath) -> UITableViewCell {
        let cell: BurgerCell = tableView.dequeueReusableCell(for: indexPath)
        self.cell = cell
        delegate.didRequestImage()
        
        return cell
    }
    
    func display(_ model: BurgerImageViewModel<UIImage>) {
        guard let cell = self.cell else { return }
        cell.nameLabel.text = model.name
        cell.descriptionLabel.text = model.description
        cell.descriptionLabel.isHidden = !model.hasDescription
        
        cell.burgerImageView.setImageAnimated(model.image)
        model.isLoading ? cell.imageContainer.startShimmering() : cell.imageContainer.stopShimmering()
        
        cell.onRetry = delegate.didRequestImage
        cell.burgerImageRetryButton.isHidden = !model.shouldRetry
    }
    
    func preload() {
        delegate.didRequestImage()
    }
    
    func cancelLoad() {
        delegate.didCancelImageRequest()
        releaseCellForReuse()
    }
    
    private func releaseCellForReuse() {
        cell = nil
    }
}

//final class BurgerCellController {
//
//    private var viewModel: BurgerImageViewModel<UIImage>
//
//    init(viewModel: BurgerImageViewModel<UIImage>) {
//        self.viewModel = viewModel
//    }
//
//    func view() -> UITableViewCell {
//        let cell = binded(BurgerCell())
//        viewModel.loadImageData()
//
//        return cell
//    }
//
//    func binded(_ cell: BurgerCell) -> UITableViewCell {
//        cell.nameLabel.text = viewModel.name
//        cell.descriptionLabel.text = viewModel.description
//        cell.descriptionLabel.isHidden = !viewModel.hasDescription
//        cell.burgerImageView.image = nil
//        cell.burgerImageRetryButton.isHidden = true
//        cell.onRetry = viewModel.loadImageData
//
//        viewModel.onImageLoad = { [weak cell] image in
//            cell?.burgerImageView.image = image
//        }
//
//        viewModel.onImageLoadingStateChange = { [weak cell] isLoading in
//            isLoading ? cell?.imageContainer.startShimmering() : cell?.imageContainer.stopShimmering()
//        }
//
//        viewModel.onShouldRetryImageLoadStateChange = { [weak cell] shouldRetry in
//            cell?.burgerImageRetryButton.isHidden = !shouldRetry
//        }
//
//        return cell
//    }
//
//    func preload() {
//        viewModel.loadImageData()
//    }
//
//    func cancelLoad() {
//        viewModel.cancelImageDataLoad()
//    }
//}
