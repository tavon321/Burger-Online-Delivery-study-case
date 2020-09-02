//
//  LocalBurgerLoader.swift
//  BurgerList
//
//  Created by Gustavo Londono on 9/2/20.
//  Copyright © 2020 Gustavo Londono. All rights reserved.
//

import Foundation

final public class LocalBurgerLoader {
    private let store: BurgerStore
    private let currentDate: () -> Date
    
    public init(store: BurgerStore, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }
    
    public func save(_ items: [Burger], completion: @escaping (Error?) -> Void) {
        store.deleteCacheFeed { [weak self] error in
            guard let self = self else { return }
            if let cacheDeletionError = error {
                completion(cacheDeletionError)
            } else {
                self.cache(items: items, completion: completion)
            }
        }
    }
    
    private func cache(items: [Burger], completion: @escaping (Error?) -> Void) {
        store.insert(items, timestamp: self.currentDate()) { [weak self] insertionError in
            guard self != nil else { return }
            completion(insertionError)
        }
    }
}
