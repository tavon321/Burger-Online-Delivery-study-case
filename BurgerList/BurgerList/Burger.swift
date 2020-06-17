//
//  Burger.swift
//  BurgerList
//
//  Created by Gustavo Londono on 6/3/20.
//  Copyright © 2020 Gustavo Londono. All rights reserved.
//

import Foundation

public struct Burger: Equatable {
    let id: UUID
    let name: String
    let description: String?
    let image: URL?
}
