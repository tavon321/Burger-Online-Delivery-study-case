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

        do {
            let decoder = JSONDecoder()
            let cache = try decoder.decode(Cache.self, from: data)
            let cachedBurgers = CachedBurgers(burgers: cache.localBuger, timestamp: cache.timestamp)
            completion(.success(cachedBurgers))
        } catch {
            completion(.failure(error))
        }
    }

    func insert(_ items: [LocalBurger], timestamp: Date, completion: @escaping BurgerStore.InsertionCompletion) {
        do {
            let encoder = JSONEncoder()
            let cache = Cache(burgers: items.map(CodableLocalBurger.init), timestamp: timestamp)
            let encoded = try encoder.encode(cache)

            try encoded.write(to: storeUrl)
            completion(nil)
        } catch {
            completion(error)
        }
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

        expect(sut, toRetrieveTwiceWith: .success(nil))
    }

    func test_retrievee_deliversValueOnNonEmptyCache() {
        let sut = makeSUT()
        let expectedBurgers = uniqueBurgers().localItems
        let expectedTimestamp = Date()

        insert(expectedBurgers, at: expectedTimestamp, to: sut)

        expect(sut, toCompleteWith: .success(CachedBurgers(burgers: expectedBurgers,
                                                           timestamp: expectedTimestamp)))
    }

    func test_retrieve_hasNoSideEffectsOnNonEmptyCache() {
        let sut = makeSUT()
        let expectedBurgers = uniqueBurgers().localItems
        let expectedTimestamp = Date()

        insert(expectedBurgers, at: expectedTimestamp, to: sut)

        expect(sut, toRetrieveTwiceWith: .success(CachedBurgers(burgers: expectedBurgers,
                                                                timestamp: expectedTimestamp)))
    }

    func test_retreive_deliersFaiilureOnRetreivalError() {
        let storeURL = testStoreUrl()
        let sut = makeSUT(url: storeURL)

        // Write an invalid String file
        try! "Invalid data".write(to: storeURL, atomically: false, encoding: .utf8)

        expect(sut, toCompleteWith: .failure(anyError))
    }

    func test_retreive_hasNoSideEffectsOnFailure() {
        let storeURL = testStoreUrl()
        let sut = makeSUT(url: storeURL)

        try! "Invalid data".write(to: storeURL, atomically: false, encoding: .utf8)

        expect(sut, toCompleteWith: .failure(anyError))
    }

    func test_insert_overridesProviouslyInsertedValues() {
        // When
        let sut = makeSUT()
        let firstInsertionError = insert(uniqueBurgers().localItems, at: Date(), to: sut)
        XCTAssertNil(firstInsertionError)

        // Given
        let latestBurgers = uniqueBurgers().localItems
        let latestTimestamp = Date()
        let latestInsertionError = insert(latestBurgers, at: latestTimestamp, to: sut)
        XCTAssertNil(latestInsertionError)

        // Then
        expect(sut, toCompleteWith: .success(CachedBurgers(burgers: latestBurgers,
                                                           timestamp: latestTimestamp)))
    }

    func test_insert_deliversErrorOnInsertionError() {
        let invalidUrl = URL(string: "invalid://store-url")!
        let sut = makeSUT(url: invalidUrl)

        let insertionError = insert(uniqueBurgers().localItems, at: Date(), to: sut)

        XCTAssertNotNil(insertionError)
    }

    // MARK: - Helpers
    private func makeSUT(url: URL? = nil, file: StaticString = #file, line: UInt = #line) -> CodableBurgerStore {
        let sut = CodableBurgerStore(storeUrl: url ?? testStoreUrl())

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
            case (.success(.none), .success(.none)), (.failure, .failure):
                break
            case let (.success(receivedCache), .success(expectedCache)):
                XCTAssertEqual(receivedCache?.burgers, expectedCache?.burgers)
                XCTAssertEqual(receivedCache?.timestamp, expectedCache?.timestamp)
            default:
                XCTFail("Expected \(expectedResult), got \(receivedResult) instead" , file: file, line: line)
            }

            exp.fulfill()
        }

        wait(for: [exp], timeout: 0.1)
    }

    @discardableResult
    private func insert(_ burgers: [LocalBurger], at timestamp: Date, to sut: CodableBurgerStore) -> Error? {
        let exp = expectation(description: "wait for cache insetion")

        var insertionError: Error?
        sut.insert(burgers, timestamp: timestamp) { receivedError in
            insertionError = receivedError
            exp.fulfill()
        }
        wait(for: [exp], timeout: 0.1)

        return insertionError
    }

    private func expect(_ sut: CodableBurgerStore,
                        toRetrieveTwiceWith expectedResult: Result<CachedBurgers?, Error>,
                        file: StaticString = #file,
                        line: UInt = #line) {
        expect(sut, toCompleteWith: expectedResult, file: file, line: line)
        expect(sut, toCompleteWith: expectedResult, file: file, line: line)
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
