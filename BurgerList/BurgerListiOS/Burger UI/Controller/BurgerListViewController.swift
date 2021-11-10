//
//  BurgerListViewController.swift
//  BurgerListiOS
//
//  Created by Gustavo on 23/08/21.
//  Copyright © 2021 Gustavo Londono. All rights reserved.
//

import UIKit
import BurgerList

public final class BurgerListViewController: UITableViewController, UITableViewDataSourcePrefetching {
    private var refreshController: BurgersRefreshViewController?
    private var imageLoader: BurgerImageLoader?
    
    private var tableModel = [Burger]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    private var cellControllers = [IndexPath: BurgerCellController]()
    
    public convenience init(burgerLoader: BurgerLoader,
                            imageLoader: BurgerImageLoader) {
        self.init()
        
        self.refreshController =
        BurgersRefreshViewController(burgerLoader: burgerLoader)
        self.imageLoader = imageLoader
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshControl = refreshController?.view
        refreshController?.onRefresh = { [weak self] burgers in
            self?.tableModel = burgers
        }
        tableView.prefetchDataSource = self
        
        refreshController?.refresh()
    }
    
    public override func tableView(_ tableView: UITableView,
                                   numberOfRowsInSection section: Int) -> Int {
        return tableModel.count
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return cellController(forRowAt: indexPath).view()
    }
    
    public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard tableModel[indexPath.row].imageURL != nil else { return }
        cellControllers[indexPath] = nil
        removeCellController(forRowAt: indexPath)
    }
    
    public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            cellController(forRowAt: indexPath).preload()
        }
    }
    
    public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach(removeCellController)
    }
    
    private func removeCellController(forRowAt indexPath: IndexPath) {
        cellControllers[indexPath] = nil
    }
    
    private func cellController(forRowAt indexPath: IndexPath) -> BurgerCellController {
        let cellModel = tableModel[indexPath.row]
        let cellContoller = BurgerCellController(model: cellModel, imageLoader: imageLoader!)
        
        cellControllers[indexPath] = cellContoller
        return cellContoller
    }
}
