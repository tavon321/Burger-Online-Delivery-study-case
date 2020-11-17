//
//  LocalBurger.swift
//  BurgerList
//
//  Created by Gustavo Londono on 9/14/20.
//  Copyright © 2020 Gustavo Londono. All rights reserved.
//

import Foundation

public struct LocalBurger: Equatable, Codable {
    public let id: UUID
    public let name: String
    public let description: String?
    public let imageURL: URL?
    
    public init(id: UUID, name: String, description: String?, imageURL: URL?) {
        self.id = id
        self.name = name
        self.description = description
        self.imageURL = imageURL
    }
}
