//
//  BurgerStore.swift
//  BurgerList
//
//  Created by Gustavo Londono on 8/31/20.
//  Copyright © 2020 Gustavo Londono. All rights reserved.
//

import Foundation

public typealias CachedBurgers = (burgers: [LocalBurger], timestamp: Date)

public protocol BurgerStore {
    typealias DeletionCompletion = (Error?) -> Void
    typealias InsertionCompletion = (Error?) -> Void
    typealias RetreivalCompletion = (Result<CachedBurgers?, Error>) -> Void

    /*
     The completion handler can be invoked in any thread.
     Clients are responsible to dispatch to appropiate threads, if needed.
     */
    func deleteCacheFeed(completion: @escaping DeletionCompletion)

    /*
     The completion handler can be invoked in any thread.
     Clients are responsible to dispatch to appropiate threads, if needed.
     */
    func insert(_ items: [LocalBurger], timestamp: Date, completion: @escaping InsertionCompletion)

    /*
     The completion handler can be invoked in any thread.
     Clients are responsible to dispatch to appropiate threads, if needed.
     */
    func retrieve(completion: @escaping RetreivalCompletion)
}
