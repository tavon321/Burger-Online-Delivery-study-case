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
        let burgers: [CodableLocalBurger]
        let timestamp: Date

        var localBuger: [LocalBurger] {
            return burgers.map({ $0.local })
        }
    }

    private struct CodableLocalBurger: Equatable, Codable {
        public let id: UUID
        public let name: String
        public let description: String?
        public let imageURL: URL?

        init(_ local: LocalBurger) {
            self.id = local.id
            self.name = local.name
            self.description = local.description
            self.imageURL = local.imageURL
        }

        var local: LocalBurger {
            LocalBurger(id: id, name: name, description: description, imageURL: imageURL)
        }
    }

    private let storeUrl: URL

    init(storeUrl: URL) {
        self.storeUrl = storeUrl
    }

    func retreive(completion: @escaping BurgerStore.RetreivalCompletion) {
        guard let data = try? Data(contentsOf: storeUrl) else {
            return completion(.success(nil))
        }
        let decoder = JSONDecoder()
        let cache = try! decoder.decode(Cache.self, from: data)
        let cachedBurgers = CachedBurgers(burgers: cache.localBuger, timestamp: cache.timestamp)

        completion(.success(cachedBurgers))
    }

    func insert(_ items: [LocalBurger], timestamp: Date, completion: @escaping BurgerStore.InsertionCompletion) {
        let encoder = JSONEncoder()
        let cache = Cache(burgers: items.map(CodableLocalBurger.init), timestamp: timestamp)
        let encoded = try! encoder.encode(cache)

        try! encoded.write(to: storeUrl)

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
        let sut = makeSUT()

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
        let sut = makeSUT()

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
        let sut = makeSUT()
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

    // MARK: - Helpers
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> CodableBurgerStore {
        let storeUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("burgers.store")
        let sut = CodableBurgerStore(storeUrl: storeUrl)

        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
}
