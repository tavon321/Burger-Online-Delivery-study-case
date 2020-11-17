//
//  LocalBurgerLoader.swift
//  BurgerList
//
//  Created by Gustavo Londono on 9/2/20.
//  Copyright © 2020 Gustavo Londono. All rights reserved.
//

import Foundation

final public class LocalBurgerLoader: BurgerLoader {
    private let store: BurgerStore
    private let currentDate: () -> Date

    public typealias SaveResult = Error?
    
    public init(store: BurgerStore, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }
}

extension LocalBurgerLoader {
    public func load(completion: @escaping (BurgerLoader.Result) -> Void) {
        store.retreive { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let cachedBurgers):
                guard let cachedBurgers = cachedBurgers,
                      BurgerCachePolicy.validate(cachedBurgers.timestamp, against: self.currentDate()) else {
                    return completion(.success([]))
                }

                completion(.success(cachedBurgers.burgers.toModels))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}

extension LocalBurgerLoader {
    public func save(_ items: [Burger], completion: @escaping (SaveResult) -> Void) {
        store.deleteCacheFeed { [weak self] error in
            guard let self = self else { return }
            if let cacheDeletionError = error {
                completion(cacheDeletionError)
            } else {
                self.cache(items: items, completion: completion)
            }
        }
    }

    private func cache(items: [Burger], completion: @escaping (SaveResult) -> Void) {
        store.insert(items.toLocal, timestamp: self.currentDate()) { [weak self] insertionError in
            guard self != nil else { return }
            completion(insertionError)
        }
    }
}

extension LocalBurgerLoader {
    public func validateCache() {
        store.retreive { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let cachedBurgers):
                if let cachedBurgers = cachedBurgers, !BurgerCachePolicy.validate(cachedBurgers.timestamp,
                                                                                  against: self.currentDate()) {
                    self.store.deleteCacheFeed { _ in }
                }
            case .failure:
                self.store.deleteCacheFeed { _ in }
            }
        }
    }
}

private extension Array where Element == Burger {
    
    var toLocal: [LocalBurger] {
        return map { LocalBurger(id: $0.id, name: $0.name, description: $0.description, imageURL: $0.imageURL) }
    }
}

private extension Array where Element == LocalBurger {
    
    var toModels: [Burger] {
        return map { Burger(id: $0.id, name: $0.name, description: $0.description, imageURL: $0.imageURL) }
    }
}
