//
//  BurgerCachePolicy.swift
//  BurgerList
//
//  Created by Tavo on 29/10/20.
//  Copyright © 2020 Gustavo Londono. All rights reserved.
//

import Foundation

internal struct BurgerCachePolicy {
    static private let calendar = Calendar(identifier: .gregorian)
    static private let maxCacheAgeInDays = 14

    private init() {}

    static func validate(_ timestamp: Date, against date: Date) -> Bool {
        guard let maxCacheAge = calendar.date(byAdding: .day, value: maxCacheAgeInDays, to: timestamp) else {
            return false
        }

        return date < maxCacheAge
    }
}
