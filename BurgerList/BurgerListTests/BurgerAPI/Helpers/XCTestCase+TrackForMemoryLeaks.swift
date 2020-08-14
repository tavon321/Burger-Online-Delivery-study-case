//
//  XCTestCase+TrackForMemoryLeaks.swift
//  BurgerListTests
//
//  Created by Gustavo Londono on 7/24/20.
//  Copyright © 2020 Gustavo Londono. All rights reserved.
//

import XCTest

extension XCTestCase {
    func trackForMemoryLeaks(_ object: AnyObject, file: StaticString = #file, line: UInt = #line) {
        addTeardownBlock { [weak object] in
            XCTAssertNil(object, "Instance should have being deallocated. Potential memory leak", file: file, line: line)
        }
    }
}
