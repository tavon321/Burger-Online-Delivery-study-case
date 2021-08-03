//
//  BurgerListCell.swift
//  BurgerList-iOS
//
//  Created by Gustavo on 3/08/21.
//

import UIKit

class BurgerListCell: UITableViewCell {
    @IBOutlet private(set) var imageContainer: UIView!
    @IBOutlet private(set) var burgerImageView: UIImageView!
    @IBOutlet private(set) var titleLabel: UILabel!
    @IBOutlet private(set) var descriptionLabel: UILabel!
}
