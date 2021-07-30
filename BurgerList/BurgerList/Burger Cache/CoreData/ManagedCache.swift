//
//  ManagedCache.swift
//  BurgerList
//
//  Created by Gustavo on 7/04/21.
//  Copyright © 2021 Gustavo Londono. All rights reserved.
//

import CoreData

@objc(ManagedCache)
internal class ManagedCache: NSManagedObject {
    @NSManaged internal var timestamp: Date
    @NSManaged internal var burgers: NSOrderedSet
}

extension ManagedCache {
    internal static func find(in context: NSManagedObjectContext) throws -> ManagedCache? {
        let request = NSFetchRequest<ManagedCache>(entityName: entity().name!)
        request.returnsObjectsAsFaults = false
        return try context.fetch(request).first
    }

    internal static func newUniqueInstance(in context: NSManagedObjectContext) throws -> ManagedCache {
        try find(in: context).map(context.delete)
        return ManagedCache(context: context)
    }

    internal var localBurgers: [LocalBurger] {
        return burgers.compactMap { ($0 as? ManagedBurger)?.local }
    }
}
