//
//  XCTestCase+FailableRetreiveBurgerSpecs.swift
//  BurgerListTests
//
//  Created by Gustavo Londoño on 17/03/21.
//  Copyright © 2021 Gustavo Londono. All rights reserved.
//

import XCTest
import BurgerList

extension FailableRetrieveBurgerStoreSpecs where Self: XCTestCase {
    func assertRetrieveDeliversFailureOnRetrievalError(for sut: BurgerStore, file: StaticString = #file, line: UInt = #line) {
        expect(sut, toRetrieve: .failure(anyError), file: file, line: line)
    }

    func assertRetrieveHasNoSideEffectsOnFailure(for sut: BurgerStore, file: StaticString = #file, line: UInt = #line) {
        expect(sut, toRetrieveTwiceWith: .failure(anyError))
    }
}
