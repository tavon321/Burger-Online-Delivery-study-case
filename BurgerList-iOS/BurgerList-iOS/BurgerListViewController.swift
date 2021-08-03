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

class BurgerListViewController: UITableViewController {
    private let burgers = BurgerListViewModel.prototypeFeed
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return burgers.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BurgerCell", for: indexPath) as! BurgerListCell
        
        cell.configure(with: burgers[indexPath.row])
        
        return cell
    }
}

extension BurgerListCell {
    func configure(with viewModel: BurgerListViewModel) {
        titleLabel.text = viewModel.title
        
        descriptionLabel.text = viewModel.description
        descriptionLabel.isHidden = viewModel.description == nil
        
        burgerImageView.image = UIImage(named: viewModel.imageName ?? "placeholder")
    }
}
