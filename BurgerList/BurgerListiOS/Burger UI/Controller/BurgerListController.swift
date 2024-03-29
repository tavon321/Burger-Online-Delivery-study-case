//
//  BurgerListController.swift
//  BurgerListiOS
//
//  Created by Gustavo on 23/08/21.
//  Copyright © 2021 Gustavo Londono. All rights reserved.
//

import UIKit
import BurgerList

public final class BurgerListController: UITableViewController, UITableViewDataSourcePrefetching, BurgerErrorView {
    
    private let refreshController: BurgersRefreshViewController
    @IBOutlet private(set) public var errorView: ErrorView?
    
    var cellControllers = [BurgerCellController]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    init?(coder: NSCoder, refreshController: BurgersRefreshViewController) {
        self.refreshController = refreshController
        
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshControl = refreshController.view
        tableView.prefetchDataSource = self
        
        refreshController.refresh()
    }
    
    public func display(_ viewModel: BurgerErrorViewModel) {
        errorView?.message = viewModel.errorMessage
    }
    
    public override func tableView(_ tableView: UITableView,
                                   numberOfRowsInSection section: Int) -> Int {
        return cellControllers.count
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return cellController(forRowAt: indexPath).view(tableView: tableView,
                                                        for: indexPath)
    }
    
    public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cancelCellControllerLoad(forRowAt: indexPath)
    }
    
    public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            cellController(forRowAt: indexPath).preload()
        }
    }
    
    public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach(cancelCellControllerLoad)
    }
    
    private func cancelCellControllerLoad(forRowAt indexPath: IndexPath) {
        cellController(forRowAt: indexPath).cancelLoad()
    }
    
    private func cellController(forRowAt indexPath: IndexPath) -> BurgerCellController {
        return cellControllers[indexPath.row]
    }
}
