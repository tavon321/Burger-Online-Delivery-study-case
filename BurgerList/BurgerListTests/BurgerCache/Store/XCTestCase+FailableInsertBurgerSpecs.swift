//
//  XCTestCase+FailableInsertBurgerSpecs.swift
//  BurgerListTests
//
//  Created by Gustavo Londoño on 17/03/21.
//  Copyright © 2021 Gustavo Londono. All rights reserved.
//

import XCTest
import BurgerList

extension FailableInsertBurgerStoreSpecs where Self: XCTestCase {
    func assertInsertDeliversErrorOnInsertionError(for sut: BurgerStore, file: StaticString = #file, line: UInt = #line) {
        let insertionError = insert(uniqueBurgers().localItems, at: Date(), to: sut)

        XCTAssertNotNil(insertionError, file: file, line: line)
    }
    
    func assertInsertHasNoSideEffectsOnInsertionError(for sut: BurgerStore, file: StaticString = #file, line: UInt = #line) {
        let timestamp = Date()
        let burgers = uniqueBurgers().localItems
        
        insert(burgers, at: timestamp, to: sut)

        expect(sut, toRetrieve: .success(.none))
    }
}

