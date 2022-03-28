//
//  XCTestCase+Localized.swift
//  BurgerListiOSTests
//
//  Created by Gustavo on 17/01/22.
//  Copyright © 2022 Gustavo Londono. All rights reserved.
//

import XCTest
import BurgerList

extension XCTestCase {
    func localized(_ key: String, file: StaticString = #file, line: UInt = #line) -> String {
        let table = "Burgers"
        let bundle = Bundle(for: BurgersPresenter.self)
        let value = bundle.localizedString(forKey: key, value: nil, table: table)
        if value == key {
            XCTFail("Missing localized string for key: \(key) in table: \(table)", file: file, line: line)
        }
        return value
    }
}
