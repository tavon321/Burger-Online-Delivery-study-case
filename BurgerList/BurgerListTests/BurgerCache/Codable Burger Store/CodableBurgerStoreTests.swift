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

    private struct Cache: Codable {
        let burgers: [LocalBurger]
        let timestamp: Date
    }

    private let storeURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("burgers.store")

    func retreive(completion: @escaping BurgerStore.RetreivalCompletion) {
        guard let data = try? Data(contentsOf: storeURL) else {
            return completion(.success(nil))
        }
        let decoder = JSONDecoder()
        let cache = try! decoder.decode(Cache.self, from: data)
        let cachedBurgers = CachedBurgers(burgers: cache.burgers, timestamp: cache.timestamp)

        completion(.success(cachedBurgers))
    }

    func insert(_ items: [LocalBurger], timestamp: Date, completion: @escaping BurgerStore.InsertionCompletion) {
        let encoder = JSONEncoder()
        let encoded = try! encoder.encode(Cache(burgers: items, timestamp: timestamp))

        try! encoded.write(to: storeURL)

        completion(nil)
    }
}

class CodableBurgerStoreTests: XCTestCase {

    override class func setUp() {
        super.setUp()

        let storeURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("burgers.store")
        try? FileManager.default.removeItem(at: storeURL)
    }

    override func tearDown() {
        super.tearDown()

        let storeURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("burgers.store")
        try? FileManager.default.removeItem(at: storeURL)
    }

    func test_retrieve_deliversEmptyOnEmptyCache() {
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

    func test_retrieve_hasNoSideEffectsOnEmptyCache() {
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

    func test_retrieveAfterInsertingToEmptyCache_deliversInsertedValues() {
        let sut = CodableBurgerStore()
        let expectedBurgers = uniqueBurgers().localItems
        let expectedTimestamp = Date()

        let exp = expectation(description: "wait for retrieval")
        sut.insert(expectedBurgers, timestamp: expectedTimestamp) { insertionError in
            XCTAssertNil(insertionError, "Expected Burgers to ve insterted succesfully")
            sut.retreive { retrieveResult in
                switch (retrieveResult) {
                case let .success(cachedBurgers):
                    XCTAssertEqual(cachedBurgers?.burgers, expectedBurgers)
                    XCTAssertEqual(cachedBurgers?.timestamp, expectedTimestamp)
                default:
                    XCTFail("Expected succes with \(expectedBurgers) and \(expectedTimestamp), got \(retrieveResult) instead")
                }
            }
            exp.fulfill()
        }

        wait(for: [exp], timeout: 0.1)
    }
}
