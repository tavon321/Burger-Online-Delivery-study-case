//
//  FeedItemsMapper.swift
//  BurgerList
//
//  Created by Gustavo Londono on 6/25/20.
//  Copyright © 2020 Gustavo Londono. All rights reserved.
//

import Foundation

internal final class BurgerItemsMapper {
    
    private static var ok200 = 200
    
    private struct BurgerRoot: Decodable {
        let items: [RemoteBurger]
    }
    
    private struct RemoteBurger: Decodable {
        let id: UUID
        let name: String
        let description: String?
        let image: URL?
        
        var burger: Burger {
            return Burger(id: id,
                          name: name,
                          description: description,
                          imageURL: image)
        }
    }
    
    internal static func map(_ data: Data, response: HTTPURLResponse) throws -> [Burger] {
        guard response.statusCode == ok200 else {
            throw RemoteBurgerLoader.Error.invalidData
        }
        
        let root = try JSONDecoder().decode(BurgerRoot.self, from: data)
        return root.items.map({ $0.burger })
    }
}
