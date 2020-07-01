//
//  BurgerLoader.swift
//  BurgerList
//
//  Created by Gustavo Londono on 6/3/20.
//  Copyright © 2020 Gustavo Londono. All rights reserved.
//

import Foundation

public protocol BurgerLoader {
    typealias BurgerListResult = Result<[Burger], Error>
    
    func load(completion: @escaping (BurgerListResult) -> Void)
}
