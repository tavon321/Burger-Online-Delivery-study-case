//
//  SharedTestHelpers.swift
//  BurgerListTests
//
//  Created by Tavo on 30/09/20.
//  Copyright © 2020 Gustavo Londono. All rights reserved.
//

import Foundation

var anyURL: URL { return URL(string: "https://a-url.com")! }

var anyError: NSError { return NSError(domain: "any error", code: 0) }

var anyData: Data { return Data("any data".utf8) }

extension Date {
    func adding(days: Int) -> Date {
        return Calendar(identifier: .gregorian).date(byAdding: .day, value: days, to: self)!
    }

    func adding(seconds: TimeInterval) -> Date {
        return self + seconds
    }
}
