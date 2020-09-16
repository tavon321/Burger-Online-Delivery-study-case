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
    func retreive()
}
