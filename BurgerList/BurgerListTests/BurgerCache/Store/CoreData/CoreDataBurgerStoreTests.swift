//
//  CoreDataBurgerStoreTests.swift
//  BurgerListTests
//
//  Created by Gustavo on 7/04/21.
//  Copyright © 2021 Gustavo Londono. All rights reserved.
//

import Foundation

import XCTest
import BurgerList

class CoreDataBurgerStoreTests: XCTestCase, BurgerStoreSpecs {
    func test_retrieve_deliversEmptyOnEmptyCache() {
        let sut = makeSUT()
        
        assertRetrieveDeliversEmptyOnEmptyCache(for: sut)
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
    
    func test_insert_overridesProviouslyInsertedValues() {
        let sut = makeSUT()
        
        assertInsertOverridesPreviouslyInsertedValues(for: sut)
    }
    
    func test_delete_emptiesPreviouslyInsertedCache() {
        let sut = makeSUT()
        
        assertDeleteEmptiesPreviouslyInsertedCache(for: sut)
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
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> CoreDataBurgerStore {
        let storeURL = URL(fileURLWithPath: "/dev/null")
        let sut = try! CoreDataBurgerStore(storeURL: storeURL)
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
}
