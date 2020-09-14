//
//  BurgerStore.swift
//  BurgerList
//
//  Created by Gustavo Londono on 8/31/20.
//  Copyright © 2020 Gustavo Londono. All rights reserved.
//

import Foundation

public protocol BurgerStore {
    typealias DeletionCompletion = (Error?) -> Void
    typealias InsertionCompletion = (Error?) -> Void
    
    func deleteCacheFeed(completion: @escaping DeletionCompletion)
    func insert(_ items: [LocalBurger], timestamp: Date, completion: @escaping (Error?) -> Void)
}

public struct LocalBurger: Equatable {
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
