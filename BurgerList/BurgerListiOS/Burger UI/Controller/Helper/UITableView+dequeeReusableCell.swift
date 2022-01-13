//
//  UITableView+dequeeReusableCell.swift
//  BurgerListiOS
//
//  Created by Gustavo on 13/01/22.
//  Copyright © 2022 Gustavo Londono. All rights reserved.
//

import UIKit

private extension UITableView {
    func dequeueReusableCell<T: UITableViewCell>(for indexPath: IndexPath) -> T {
        let identifier = String(describing: T.self)
        return dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! T
    }
}
