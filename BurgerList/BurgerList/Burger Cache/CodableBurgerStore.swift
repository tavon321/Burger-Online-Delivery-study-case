//
//  CodableBurgerStore.swift
//  BurgerList
//
//  Created by Tavo on 9/03/21.
//  Copyright © 2021 Gustavo Londono. All rights reserved.
//

import Foundation

public class CodableBurgerStore: BurgerStore {

    private struct Cache: Codable {
        let burgers: [CodableLocalBurger]
        let timestamp: Date

        var localBuger: [LocalBurger] {
            return burgers.map({ $0.local })
        }
    }

    private struct CodableLocalBurger: Equatable, Codable {
        public let id: UUID
        public let name: String
        public let description: String?
        public let imageURL: URL?

        init(_ local: LocalBurger) {
            self.id = local.id
            self.name = local.name
            self.description = local.description
            self.imageURL = local.imageURL
        }

        var local: LocalBurger {
            LocalBurger(id: id, name: name, description: description, imageURL: imageURL)
        }
    }

    private let storeUrl: URL

    public init(storeUrl: URL) {
        self.storeUrl = storeUrl
    }

    public func retrieve(completion: @escaping BurgerStore.RetreivalCompletion) {
        guard let data = try? Data(contentsOf: storeUrl) else {
            return completion(.success(nil))
        }

        do {
            let decoder = JSONDecoder()
            let cache = try decoder.decode(Cache.self, from: data)
            let cachedBurgers = CachedBurgers(burgers: cache.localBuger, timestamp: cache.timestamp)
            completion(.success(cachedBurgers))
        } catch {
            completion(.failure(error))
        }
    }

    public func insert(_ items: [LocalBurger], timestamp: Date, completion: @escaping BurgerStore.InsertionCompletion) {
        do {
            let encoder = JSONEncoder()
            let cache = Cache(burgers: items.map(CodableLocalBurger.init), timestamp: timestamp)
            let encoded = try encoder.encode(cache)

            try encoded.write(to: storeUrl)
            completion(nil)
        } catch {
            completion(error)
        }
    }

    public func deleteCacheFeed(completion: @escaping BurgerStore.DeletionCompletion) {
        guard FileManager.default.fileExists(atPath: storeUrl.path) else {
            return completion(nil)
        }
        do {
            try FileManager.default.removeItem(at: storeUrl)
            completion(nil)
        } catch {
            completion(error)
        }
    }
}
