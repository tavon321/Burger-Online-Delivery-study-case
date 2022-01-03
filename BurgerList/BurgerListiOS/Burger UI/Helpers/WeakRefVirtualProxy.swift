//
//  WeakRefVirtualProxy.swift
//  BurgerListiOS
//
//  Created by Gustavo on 3/01/22.
//  Copyright © 2022 Gustavo Londono. All rights reserved.
//

import Foundation

final class WeakRefVirtualProxy<T: AnyObject> {
    weak var object: T?
    
    init(_ object: T) {
        self.object = object
    }
}
