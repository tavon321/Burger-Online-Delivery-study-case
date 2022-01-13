//
//  BurgerCell.swift
//  BurgerListiOS
//
//  Created by Gustavo on 31/08/21.
//  Copyright © 2021 Gustavo Londono. All rights reserved.
//

import UIKit

public class BurgerCell: UITableViewCell {
    @IBOutlet private(set) public var nameLabel: UILabel!
    @IBOutlet private(set) public var descriptionLabel: UILabel!
    @IBOutlet private(set) public var imageContainer: UIView!
    @IBOutlet private(set) public var burgerImageView: UIImageView!
    @IBOutlet private(set) public var burgerImageRetryButton: UIButton!
    
    var onRetry: (() -> Void)?
    
    @IBAction private func retryButtonTapped() {
        onRetry?()
    }
}
