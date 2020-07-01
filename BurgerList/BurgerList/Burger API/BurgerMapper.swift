//
//  BurgerMapper.swift
//  BurgerList
//
//  Created by Gustavo Londono on 6/25/20.
//  Copyright © 2020 Gustavo Londono. All rights reserved.
//

import Foundation

internal final class BurgerMapper {
    
    private static var ok200 = 200
    
    private struct BurgerRoot: Decodable {
        let items: [RemoteBurger]
        
        var burgers: [Burger] {
            return items.map({ $0.burger })
        }
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
    
    internal static func map(_ data: Data, response: HTTPURLResponse) -> RemoteBurgerLoader.Result {
        guard response.statusCode == ok200, let root = try? JSONDecoder().decode(BurgerRoot.self, from: data) else {
            return .failure(RemoteBurgerLoader.Error.invalidData)
        }
        return .success(root.burgers)
    }
}
