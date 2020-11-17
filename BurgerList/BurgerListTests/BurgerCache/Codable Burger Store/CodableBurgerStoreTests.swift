//
//  CodableBurgerStoreTests.swift
//  BurgerListTests
//
//  Created by Tavo on 17/11/20.
//  Copyright © 2020 Gustavo Londono. All rights reserved.
//

import XCTest
import BurgerList

class CodableBurgerStore {
    func retreive(completion: @escaping BurgerStore.RetreivalCompletion) {
        completion(.success(nil))
    }
}

class CodableBurgerStoreTests: XCTestCase {

    func test_retreive_delivers_emptyOnEmptyCache() {
        let sut = CodableBurgerStore()

        let exp = expectation(description: "wait for retrieval")
        sut.retreive { result in
            switch result {
            case .success(let cachedBurgers):
                XCTAssertNil(cachedBurgers)
            default:
                XCTFail("Expected nil result, got \(result) instead")
            }

            exp.fulfill()
        }

        wait(for: [exp], timeout: 0.1)
    }
}
