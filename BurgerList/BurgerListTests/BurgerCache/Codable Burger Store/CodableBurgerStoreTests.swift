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

    func test_retreive_deliversEmptyOnEmptyCache() {
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

    func test_retreive_hasNoSideEffectsOnEmptyCache() {
        let sut = CodableBurgerStore()

        let exp = expectation(description: "wait for retrieval")
        sut.retreive { firstResult in
            sut.retreive { secondResult in
                switch (firstResult, secondResult) {
                case let (.success(firstCache), .success(secondCache)):
                    XCTAssertNil(firstCache)
                    XCTAssertNil(secondCache)
                default:
                    XCTFail("Expected retrieving twice from empty cache to deliver same empty result, got \(firstResult) and \(secondResult) instead")
                }
            }
            exp.fulfill()
        }

        wait(for: [exp], timeout: 0.1)
    }
}
