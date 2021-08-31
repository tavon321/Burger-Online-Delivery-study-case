//
//  BurgerListViewController.swift
//  BurgerListiOS
//
//  Created by Gustavo on 23/08/21.
//  Copyright © 2021 Gustavo Londono. All rights reserved.
//

import UIKit
import BurgerList

public final class BurgerListViewController: UITableViewController {
    private var loader: BurgerLoader?
    private var tableModel = [Burger]()
    
    public convenience init(loader: BurgerLoader) {
        self.init()
        
        self.loader = loader
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(refresh), for: .valueChanged)
        
        refresh()
    }
    
    @objc private func refresh() {
        refreshControl?.beginRefreshing()
        
        loader?.load { [weak self] result in
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
        
        return cell
    }
}
