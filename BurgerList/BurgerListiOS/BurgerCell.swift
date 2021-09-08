//
//  BurgerCell.swift
//  BurgerListiOS
//
//  Created by Gustavo on 31/08/21.
//  Copyright © 2021 Gustavo Londono. All rights reserved.
//

import UIKit

public class BurgerCell: UITableViewCell {
    public let nameLabel = UILabel()
    public let descriptionLabel = UILabel()
    public let imageContainer = UIView()
    public let burgerImageView = UIImageView()
    
    private(set) public lazy var burgerImageRetryButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(retryButtonTapped), for: .touchUpInside)
        return button
    }()
    
    var onRetry: (() -> Void)?
    
    @objc private func retryButtonTapped() {
        onRetry?()
    }
}
