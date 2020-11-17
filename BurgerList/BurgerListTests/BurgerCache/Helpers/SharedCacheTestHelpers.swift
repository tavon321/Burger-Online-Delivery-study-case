//
//  SharedCacheTestHelpers.swift
//  BurgerListTests
//
//  Created by Tavo on 30/09/20.
//  Copyright © 2020 Gustavo Londono. All rights reserved.
//

import Foundation
import BurgerList

 var uniqueBurger: Burger {
    return Burger(id: UUID(), name: "a name", description: "a description", imageURL: anyURL)
}

func uniqueBurgers() -> (models: [Burger], localItems: [LocalBurger]) {
    let items = [uniqueBurger, uniqueBurger]
    let localItems = items.map { LocalBurger(id: $0.id, name: $0.name, description: $0.description, imageURL: $0.imageURL) }

    return (models: items, localItems: localItems)
}

extension Date {

    func minusBurgerCacheMaxAge() -> Date {
        let burgerCacheMaxAgeInDays = 14
        return adding(days: -burgerCacheMaxAgeInDays)
    }

    private func adding(days: Int) -> Date {
        return Calendar(identifier: .gregorian).date(byAdding: .day, value: days, to: self)!
    }
}

extension Date {
    func adding(seconds: TimeInterval) -> Date {
        return self + seconds
    }
}
