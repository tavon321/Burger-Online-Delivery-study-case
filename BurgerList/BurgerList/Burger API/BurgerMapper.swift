//
//  BurgerMapper.swift
//  BurgerList
//
//  Created by Gustavo Londono on 6/25/20.
//  Copyright © 2020 Gustavo Londono. All rights reserved.
//

import Foundation

internal final class BurgerMapper {
    
    internal static func map(_ data: Data, response: HTTPURLResponse) throws -> [RemoteBurger] {
        guard response.isOK, let burgers = try? JSONDecoder().decode([RemoteBurger].self, from: data) else {
            throw RemoteBurgerLoader.Error.invalidData
        }
        return burgers
    }
}
