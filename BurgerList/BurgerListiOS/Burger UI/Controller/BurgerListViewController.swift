//
//  BurgerListViewController.swift
//  BurgerListiOS
//
//  Created by Gustavo on 23/08/21.
//  Copyright © 2021 Gustavo Londono. All rights reserved.
//

import UIKit
import BurgerList

public protocol BurgerImageDataLoadTask {
    func cancel()
}

public final class BurgerListViewController: UITableViewController, UITableViewDataSourcePrefetching {
    private var burgerloader: BurgerLoader?
    private var imageLoader: BurgerImageLoader?
    private var tableModel = [Burger]()
    private var tasks = [IndexPath: BurgerImageDataLoadTask]()
    
    public convenience init(burgerLoader: BurgerLoader,
                            imageLoader: BurgerImageLoader) {
        self.init()
        
        self.burgerloader = burgerLoader
        self.imageLoader = imageLoader
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(refresh), for: .valueChanged)
        tableView.prefetchDataSource = self
        
        refresh()
    }
    
    @objc private func refresh() {
        refreshControl?.beginRefreshing()
        
        burgerloader?.load { [weak self] result in
            switch result {
            case .success(let burgers):
                self?.tableModel = burgers
                self?.tableView.reloadData()
            case .failure:
                break
                
            }
            
            self?.refreshControl?.endRefreshing()
        }
    }
    
    public override func tableView(_ tableView: UITableView,
                                   numberOfRowsInSection section: Int) -> Int {
        return tableModel.count
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellModel = tableModel[indexPath.row]
        let cell = BurgerCell()
        
        cell.nameLabel.text = cellModel.name
        cell.descriptionLabel.text = cellModel.description
        cell.descriptionLabel.isHidden = cellModel.description == nil
        cell.burgerImageView.image = nil
        cell.burgerImageRetryButton.isHidden = true
        cell.imageContainer.startShimmering()
        
        let loadImage = { [weak self] in
            guard let self = self, let url = cellModel.imageURL else { return }
            self.tasks[indexPath] =
                self.imageLoader?.loadImageData(from: url) { [weak self] result in
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
    
    public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard tableModel[indexPath.row].imageURL != nil else { return }
        cancelTask(forRowAt: indexPath)
    }
    
    public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            let cellModel = tableModel[indexPath.row]
            
            guard let imageURL = cellModel.imageURL else { return }
            
            tasks[indexPath] = imageLoader?.loadImageData(from: imageURL) { _ in }
        }
    }
    
    public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            cancelTask(forRowAt: indexPath)
        }
    }
    
    private func cancelTask(forRowAt indexPath: IndexPath) {
        tasks[indexPath]?.cancel()
        tasks[indexPath] = nil
    }
}