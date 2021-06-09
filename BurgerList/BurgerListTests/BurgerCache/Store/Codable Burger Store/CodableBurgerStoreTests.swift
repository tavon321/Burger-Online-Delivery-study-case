//
//  CodableBurgerStoreTests.swift
//  BurgerListTests
//
//  Created by Tavo on 17/11/20.
//  Copyright © 2020 Gustavo Londono. All rights reserved.
//

import XCTest
import BurgerList

class CodableBurgerStoreTests: XCTestCase, FailableBurgeStore {
    
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
        
        assertRetrieveDeliversEmptyonEmptyCache(for: sut)
    }

    func test_retrieve_hasNoSideEffectsOnEmptyCache() {
        let sut = makeSUT()
        
        assertRetreiveHasNoSideEffectsOnEmptyCache(for: sut)
    }

    func test_retrieve_deliversValueOnNonEmptyCache() {
        let sut = makeSUT()
        
        assertRetreiveDeliversValueOnNonEmptyCache(for: sut)
    }

    func test_retrieve_hasNoSideEffectsOnNonEmptyCache() {
        let sut = makeSUT()
        
        assertRetreiveHasNoSideEffectsOnNonEmptyCache(for: sut)
    }

    func test_retrieve_deliversFailureOnRetrievalError() {
        let storeURL = testStoreUrl()
        let sut = makeSUT(url: storeURL)

        // Write an invalid String file
        try! "Invalid data".write(to: storeURL, atomically: false, encoding: .utf8)

        assertRetrieveDeliversFailureOnRetrievalError(for: sut)
    }

    func test_retrieve_hasNoSideEffectsOnRetrievalError() {
        let storeURL = testStoreUrl()
        let sut = makeSUT(url: storeURL)

        try! "Invalid data".write(to: storeURL, atomically: false, encoding: .utf8)
        
        assertRetrieveHasNoSideEffectsOnFailure(for: sut)
    }

    func test_insert_overridesProviouslyInsertedValues() {
        let sut = makeSUT()
        
        assertInsertOverridesPreviouslyInsertedValues(for: sut)
    }

    func test_insert_deliversErrorOnInsertionError() {
        let invalidUrl = URL(string: "invalid://store-url")!
        let sut = makeSUT(url: invalidUrl)
        
        assertInsertDeliversErrorOnInsertionError(for: sut)
    }
    
    func test_insert_hasNoSideEffectsOnInsertionError() {
        let invalidUrl = URL(string: "invalid://store-url")!
        let sut = makeSUT(url: invalidUrl)
        
        assertInsertHasNoSideEffectsOnInsertionError(for: sut)
    }

    func test_delete_emptiesPreviouslyInsertedCache() {
        let sut = makeSUT()
        
        assertDeleteEmptiesPreviouslyInsertedCache(for: sut)
    }

    func test_delete_deliversErrorOnDeletionError() {
        let nonDeletePermissionUrl = adminDirectory()
        let sut = makeSUT(url: nonDeletePermissionUrl)

        assertDeleteDeliversErrorOnInsertionError(for: sut)
    }
    
    func test_delete_hasNoSideEffectsOnDeletionError() {
        let nonDeletePermissionUrl = adminDirectory()
        let sut = makeSUT(url: nonDeletePermissionUrl)

        assertDeleteHasNoSideEffectsOnDeletionError(for: sut)
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
