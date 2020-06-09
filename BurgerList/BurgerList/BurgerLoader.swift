//
//  BurgerLoader.swift
//  BurgerList
//
//  Created by Gustavo Londono on 6/3/20.
//  Copyright © 2020 Gustavo Londono. All rights reserved.
//

import Foundation

protocol BurgerLoader {
    func load(completion: @escaping (Result<[Burger], Error>) -> Void)
}
