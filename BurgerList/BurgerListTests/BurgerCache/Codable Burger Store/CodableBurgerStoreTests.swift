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

    override func setUp() {
        super.setUp()

        setUpEmptyStoreState()
    }

    override func tearDown() {
        super.tearDown()

        undoStoreState()
    }

    func test_retrieve_deliversEmptyOnEmptyCache() {
        let sut = makeSUT()
        expect(sut, toCompleteWith: .success(nil))
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

        let exp = expectation(description: "    wait for retrieval")
        sut.insert(expectedBurgers, timestamp: expectedTimestamp) { insertionError in
            XCTAssertNil(insertionError, "Expected Burgers to ve insterted succesfully")
            exp.fulfill()
        }
        wait(for: [exp], timeout: 0.1)

        expect(sut, toCompleteWith: .success((burgers: expectedBurgers, timestamp: expectedTimestamp)))
    }

    func test_retrieve_hasNoSideEffectsOnNonEmptyCache() {
        let sut = makeSUT()
        let expectedBurgers = uniqueBurgers().localItems
        let expectedTimestamp = Date()

        let exp = expectation(description: "wait for retrieval")
        sut.insert(expectedBurgers, timestamp: expectedTimestamp) { insertionError in
            XCTAssertNil(insertionError, "Expected Burgers to ve insterted succesfully")
            sut.retreive { firstResult in
                sut.retreive { secondResult in
                    switch (firstResult, secondResult) {
                    case let (.success(cachedBurgers1), .success(cachedBurgers2)):
                        XCTAssertEqual(cachedBurgers1?.burgers, expectedBurgers)
                        XCTAssertEqual(cachedBurgers1?.timestamp, expectedTimestamp)

                        XCTAssertEqual(cachedBurgers2?.burgers, expectedBurgers)
                        XCTAssertEqual(cachedBurgers2?.timestamp, expectedTimestamp)
                    default:
                        XCTFail("Expected retrieving \(expectedBurgers) and \(expectedTimestamp) twice from cache, got \(firstResult) and \(secondResult) instead")
                    }
                }

            }
            exp.fulfill()
        }

        wait(for: [exp], timeout: 0.1)
    }

    // MARK: - Helpers
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> CodableBurgerStore {
        let sut = CodableBurgerStore(storeUrl: testStoreUrl())

        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }

    private func expect(_ sut: CodableBurgerStore,
                        toCompleteWith expectedResult: Result<CachedBurgers?, Error>,
                        file: StaticString = #file,
                        line: UInt = #line) {
        let exp = expectation(description: "Wait for result")
        sut.retreive { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedCache), .success(expectedCache)):
                XCTAssertEqual(receivedCache?.burgers, expectedCache?.burgers)
                XCTAssertEqual(receivedCache?.timestamp, expectedCache?.timestamp)
            default:
                XCTFail("Expected \(expectedResult), got \(receivedResult) instead")
            }

            exp.fulfill()
        }

        wait(for: [exp], timeout: 0.1)
    }

    func testStoreUrl() -> URL {
        FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.appendingPathComponent("\(type(of: self)).store")
    }

    private func setUpEmptyStoreState() {
        deleteStoreArtifacts()
    }

    private func undoStoreState() {
        deleteStoreArtifacts()
    }

    private func deleteStoreArtifacts() {
        try? FileManager.default.removeItem(at: testStoreUrl())
    }
}
