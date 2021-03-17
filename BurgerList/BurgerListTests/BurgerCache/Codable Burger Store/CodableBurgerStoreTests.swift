//
//  CodableBurgerStoreTests.swift
//  BurgerListTests
//
//  Created by Tavo on 17/11/20.
//  Copyright © 2020 Gustavo Londono. All rights reserved.
//

import XCTest
import BurgerList

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
        expect(sut, toRetrieve: .success(.none))
    }

    func test_retrieve_hasNoSideEffectsOnEmptyCache() {
        let sut = makeSUT()

        expect(sut, toRetrieveTwiceWith: .success(.none))
    }

    func test_retrieve_deliversValueOnNonEmptyCache() {
        let sut = makeSUT()
        let expectedBurgers = uniqueBurgers().localItems
        let expectedTimestamp = Date()

        insert(expectedBurgers, at: expectedTimestamp, to: sut)

        expect(sut, toRetrieve: .success(CachedBurgers(burgers: expectedBurgers,
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

    func test_retreive_deliversFailureOnRetreivalError() {
        let storeURL = testStoreUrl()
        let sut = makeSUT(url: storeURL)

        // Write an invalid String file
        try! "Invalid data".write(to: storeURL, atomically: false, encoding: .utf8)

        expect(sut, toRetrieve: .failure(anyError))
    }

    func test_retreive_hasNoSideEffectsOnRetreivalError() {
        let storeURL = testStoreUrl()
        let sut = makeSUT(url: storeURL)

        try! "Invalid data".write(to: storeURL, atomically: false, encoding: .utf8)
        
        expect(sut, toRetrieveTwiceWith: .failure(anyError))
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
        expect(sut, toRetrieve: .success(CachedBurgers(burgers: latestBurgers,
                                                           timestamp: latestTimestamp)))
    }

    func test_insert_deliversErrorOnInsertionError() {
        let invalidUrl = URL(string: "invalid://store-url")!
        let sut = makeSUT(url: invalidUrl)

        let insertionError = insert(uniqueBurgers().localItems, at: Date(), to: sut)

        XCTAssertNotNil(insertionError)
    }
    
    func test_insert_hasNoSideEffectsOnInsertionError() {
        let invalidUrl = URL(string: "invalid://store-url")!
        let sut = makeSUT(url: invalidUrl)
        let timestamp = Date()
        let burgers = uniqueBurgers().localItems
        
        insert(burgers, at: timestamp, to: sut)

        expect(sut, toRetrieve: .success(.none))
    }

    func test_delete_emptiesPreviouslyInsertedCache() {
        let sut = makeSUT()
        insert(uniqueBurgers().localItems, at: Date(), to: sut)

        let deletionError = deleteCache(from: sut)
        XCTAssertNil(deletionError)

        expect(sut, toRetrieve: .success(.none))
    }

    func test_delete_deliversErrorOnInsertionError() {
        let nonDeletePermissionUrl = adminDirectory()
        let sut = makeSUT(url: nonDeletePermissionUrl)

        let deletionError = deleteCache(from: sut)

        XCTAssertNotNil(deletionError, "Expected cached deletion fail")
    }
    
    func test_delete_hasNoSideEffectsOndeletionError() {
        let nonDeletePermissionUrl = adminDirectory()
        let sut = makeSUT(url: nonDeletePermissionUrl)

        deleteCache(from: sut)
        
        expect(sut, toRetrieve: .success(.none))
    }

    func test_storeSideEffects_runSerially() {
        let sut = makeSUT()

        var completeOperationsInOrder = [XCTestExpectation]()

        let op1 = expectation(description: "Operation 1")
        sut.insert(uniqueBurgers().localItems, timestamp: Date()) { _ in
            completeOperationsInOrder.append(op1)
            op1.fulfill()
        }

        let op2 = expectation(description: "Operation 2")
        sut.deleteCacheFeed { _ in
            completeOperationsInOrder.append(op2)
            op2.fulfill()
        }

        let op3 = expectation(description: "Operation 3")
        sut.deleteCacheFeed { _ in
            completeOperationsInOrder.append(op3)
            op3.fulfill()
        }

        waitForExpectations(timeout: 0.1)
        XCTAssertEqual(completeOperationsInOrder, [op1, op2, op3], "Expected side effects to run serially")
    }

    // MARK: - Helpers
    private func makeSUT(url: URL? = nil, file: StaticString = #file, line: UInt = #line) -> BurgerStore {
        let sut = CodableBurgerStore(storeUrl: url ?? testStoreUrl())

        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }

    private func expect(_ sut: BurgerStore,
                        toRetrieve expectedResult: Result<CachedBurgers?, Error>,
                        file: StaticString = #file,
                        line: UInt = #line) {
        let exp = expectation(description: "Wait for result")
        sut.retrieve { receivedResult in
            switch (receivedResult, expectedResult) {
            case (.success(.none), .success(.none)),
                 (.failure, .failure):
                break
            case let (.success(receivedCache), .success(expectedCache)):
                XCTAssertEqual(receivedCache?.burgers, expectedCache?.burgers, file: file, line: line)
                XCTAssertEqual(receivedCache?.timestamp, expectedCache?.timestamp, file: file, line: line)
            default:
                XCTFail("Expected \(expectedResult), got \(receivedResult) instead" , file: file, line: line)
            }

            exp.fulfill()
        }

        wait(for: [exp], timeout: 0.1)
    }
    
    private func expect(_ sut: BurgerStore,
                        toRetrieveTwiceWith expectedResult: Result<CachedBurgers?, Error>,
                        file: StaticString = #file,
                        line: UInt = #line) {
        expect(sut, toRetrieve: expectedResult, file: file, line: line)
        expect(sut, toRetrieve: expectedResult, file: file, line: line)
    }
    
    @discardableResult
    private func deleteCache(from sut: BurgerStore) -> Error? {
        let exp =  expectation(description: "Wait for deletion")

        var deletionError: Error?
        sut.deleteCacheFeed { receivedError in
            deletionError = receivedError
            exp.fulfill()
        }

        wait(for: [exp], timeout: 0.1)

        return deletionError
    }

    @discardableResult
    private func insert(_ burgers: [LocalBurger], at timestamp: Date, to sut: BurgerStore) -> Error? {
        let exp = expectation(description: "wait for cache insetion")

        var insertionError: Error?
        sut.insert(burgers, timestamp: timestamp) { receivedError in
            insertionError = receivedError
            exp.fulfill()
        }
        wait(for: [exp], timeout: 0.1)

        return insertionError
    }

    private func testStoreUrl() -> URL {
        FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.appendingPathComponent("\(type(of: self)).store")
    }

    private func adminDirectory() -> URL {
        return FileManager.default.urls(for: .adminApplicationDirectory, in: .systemDomainMask).first!
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
