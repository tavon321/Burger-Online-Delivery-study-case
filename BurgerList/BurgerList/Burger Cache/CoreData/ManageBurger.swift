//
//  ManageBurger.swift
//  BurgerList
//
//  Created by Gustavo on 7/04/21.
//  Copyright © 2021 Gustavo Londono. All rights reserved.
//

import CoreData

@objc(ManagedBurger)
internal class ManagedBurger: NSManagedObject {
    @NSManaged internal var id: UUID
    @NSManaged internal var name: String
    @NSManaged internal var burgerDescription: String?
    @NSManaged internal var url: URL?
    @NSManaged internal var cache: ManagedCache
}

extension ManagedBurger {
    internal static func burgers(from localBurgers: [LocalBurger], in context: NSManagedObjectContext) -> NSOrderedSet {
        return NSOrderedSet(array: localBurgers.map { local in
            let managed = ManagedBurger(context: context)
            managed.id = local.id
            managed.name = local.name
            managed.burgerDescription = local.description
            managed.url = local.imageURL
            return managed
        })
    }

    internal var local: LocalBurger {
        return LocalBurger(id: id, name: name, description: burgerDescription, imageURL: url)
    }
}
