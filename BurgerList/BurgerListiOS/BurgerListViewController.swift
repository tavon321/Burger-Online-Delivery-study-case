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

public protocol BurgerImageLoader {
    typealias Result = Swift.Result<Data, Error>
    
    func loadImageData(from url: URL,
                       completion: @escaping (Result) -> Void) -> BurgerImageDataLoadTask
}

public final class BurgerListViewController: UITableViewController {
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
        cell.imageContainer.startShimmering()
        
        if let url = cellModel.imageURL {
            tasks[indexPath] =
                imageLoader?.loadImageData(from: url) { [weak self] result in
                    guard self != nil else { return }
                    switch result {
                    case .success(let imageData):
                        cell.burgerImageView.image = UIImage(data: imageData)
                    case .failure:
                        break
                    }
                    cell.imageContainer.stopShimmering()
                }
        }
        
        return cell
    }
    
    public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard tableModel[indexPath.row].imageURL != nil else { return }
        tasks[indexPath]?.cancel()
        tasks[indexPath] = nil
    }
}
