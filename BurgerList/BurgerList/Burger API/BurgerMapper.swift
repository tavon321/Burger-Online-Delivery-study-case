//
//  BurgerMapper.swift
//  BurgerList
//
//  Created by Gustavo Londono on 6/25/20.
//  Copyright © 2020 Gustavo Londono. All rights reserved.
//

import Foundation

internal final class BurgerMapper {
    
    private struct RemoteBurger: Decodable {
        let uuid: UUID
        let name: String
        let description: String?
        let imageURL: URL?
        
        var burger: Burger {
            return Burger(id: uuid,
                          name: name,
                          description: description,
                          imageURL: imageURL)
        }
    }
    
    internal static func map(_ data: Data, response: HTTPURLResponse) -> RemoteBurgerLoader.Result {
        guard response.isOK, let burgers = try? JSONDecoder().decode([RemoteBurger].self, from: data) else {
            return .failure(RemoteBurgerLoader.Error.invalidData)
        }
        return .success(burgers.map({ $0.burger }))
    }
}
