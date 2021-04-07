//
//  CoreDataBurgerStore.swift
//  BurgerList
//
//  Created by Gustavo on 7/04/21.
//  Copyright © 2021 Gustavo Londono. All rights reserved.
//

import CoreData

public class CoreDataBurgerStore: BurgerStore {

    private let container: NSPersistentContainer
    private let context: NSManagedObjectContext

    public init(storeURL: URL, bundle: Bundle = .main) throws {
        container = try NSPersistentContainer.load(modelName: "FeedStore", url: storeURL, in: bundle)
        context = container.newBackgroundContext()
    }

    public func retrieve(completion: @escaping RetrievalCompletion) {
        perform { context in
            do {
                if let cache = try ManagedCache.find(in: context) {
                    completion(.success(CachedBurgers(burgers: cache.localFeed, timestamp: cache.timestamp)))
                } else {
                    completion(.success(nil))
                }
            } catch {
                completion(.failure(error))
            }
        }
    }

    public func insert(_ feed: [LocalBurger], timestamp: Date, completion: @escaping InsertionCompletion) {
        perform { context in
            do {
                let managedCache = try ManagedCache.newUniqueInstance(in: context)
                managedCache.timestamp = timestamp
                managedCache.burgers = ManagedBurger.burgers(from: feed, in: context)

                try context.save()
                completion(nil)
            } catch {
                completion(error)
            }
        }
    }

    public func deleteCacheFeed(completion: @escaping DeletionCompletion) {
        perform { context in
            do {
                try ManagedCache.find(in: context).map(context.delete).map(context.save)
                completion(nil)
            } catch {
                completion(error)
            }
        }
    }

    private func perform(_ action: @escaping (NSManagedObjectContext) -> Void) {
        let context = self.context
        context.perform { action(context) }
    }
}
