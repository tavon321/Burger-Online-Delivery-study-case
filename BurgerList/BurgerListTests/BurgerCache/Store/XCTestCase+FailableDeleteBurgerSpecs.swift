//
//  XCTestCase+FailableDeleteBurgerSpecs.swift
//  BurgerListTests
//
//  Created by Gustavo Londoño on 17/03/21.
//  Copyright © 2021 Gustavo Londono. All rights reserved.
//

import XCTest
import BurgerList

extension FailableDeleteBurgerStoreSpecs where Self: XCTestCase {
    func assertDeleteDeliversErrorOnInsertionError(for sut: BurgerStore, file: StaticString = #file, line: UInt = #line) {
        let deletionError = deleteCache(from: sut)

        XCTAssertNotNil(deletionError, "Expected cached deletion fail")
    }
    
    func assertDeleteHasNoSideEffectsOnDeletionError(for sut: BurgerStore, file: StaticString = #file, line: UInt = #line) {
        deleteCache(from: sut)
        
        expect(sut, toRetrieve: .success(.none))
    }
}

