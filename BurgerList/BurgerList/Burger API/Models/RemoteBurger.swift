//
//  RemoteBurger.swift
//  BurgerList
//
//  Created by Gustavo Londono on 9/14/20.
//  Copyright © 2020 Gustavo Londono. All rights reserved.
//

import Foundation

struct RemoteBurger: Decodable {
    let uuid: UUID
    let name: String
    let description: String?
    let imageURL: URL?
}
