//
//  BurgerListViewController.swift
//  BurgerList-iOS
//
//  Created by Gustavo on 3/08/21.
//

import UIKit

struct BurgerListViewModel {
    let title: String
    let description: String?
    let imageName: String?
}

protocol BurgerLoader {
    func load()
}

class BurgerListViewController: UITableViewController {
    private var burgers = [BurgerListViewModel]()
    private var loader: BurgerLoader?
    
    convenience init(loader: BurgerLoader) {
        self.init()
        self.loader = loader
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loader?.load()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let refreshControl = self.refreshControl {
            refresh(refreshControl)
        }
        tableView.setContentOffset(CGPoint(x: 0, y: -tableView.contentInset.top), animated: false)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return burgers.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BurgerCell", for: indexPath) as! BurgerListCell
        
        cell.configure(with: burgers[indexPath.row])
        
        return cell
    }
    
    @IBAction func refresh(_ sender: UIRefreshControl) {
        refreshControl?.beginRefreshing()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            if self.burgers.isEmpty {
                self.burgers = BurgerListViewModel.prototypeFeed
                self.tableView.reloadData()
            }
            self.refreshControl?.endRefreshing()
        }
    }
}

extension BurgerListCell {
    func configure(with viewModel: BurgerListViewModel) {
        titleLabel.text = viewModel.title
        
        descriptionLabel.text = viewModel.description
        descriptionLabel.isHidden = viewModel.description == nil
        
        fadeIn(UIImage(named: viewModel.imageName ?? "placeholder"))
    }
}
