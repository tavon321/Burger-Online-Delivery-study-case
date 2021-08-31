//
//  BurgerListViewController.swift
//  BurgerListiOS
//
//  Created by Gustavo on 23/08/21.
//  Copyright © 2021 Gustavo Londono. All rights reserved.
//

import UIKit
import BurgerList

public protocol BurgerImageLoader {
    func loadImageData(from url: URL)
    func cancelImageDataLoad(from url: URL)
}

public final class BurgerListViewController: UITableViewController {
    private var burgerloader: BurgerLoader?
    private var imageLoader: BurgerImageLoader?
    private var tableModel = [Burger]()
    
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
        
        if let url = cellModel.imageURL {
            imageLoader?.loadImageData(from: url)
        }
        
        return cell
    }
    
    public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let url = tableModel[indexPath.row].imageURL else { return }
        imageLoader?.cancelImageDataLoad(from: url)
    }
}
