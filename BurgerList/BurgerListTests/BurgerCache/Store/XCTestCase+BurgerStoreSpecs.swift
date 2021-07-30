//
//  XCTestCase+BurgerStoreSpecs.swift
//  BurgerListTests
//
//  Created by Gustavo Londoño on 17/03/21.
//  Copyright © 2021 Gustavo Londono. All rights reserved.
//

import XCTest
import BurgerList

extension BurgerStoreSpecs where Self: XCTestCase  {
    
    func assertRetrieveDeliversEmptyOnEmptyCache(for sut: BurgerStore, file: StaticString = #file, line: UInt = #line) {
        expect(sut, toRetrieve: .success(.none))
    }
    
    func assertRetreiveHasNoSideEffectsOnEmptyCache(for sut: BurgerStore, file: StaticString = #file, line: UInt = #line) {
        expect(sut, toRetrieveTwiceWith: .success(.none))
    }
    
    func assertRetreiveDeliversValueOnNonEmptyCache(for sut: BurgerStore, file: StaticString = #file, line: UInt = #line) {
        let expectedBurgers = uniqueBurgers().localItems
        let expectedTimestamp = Date()

        insert(expectedBurgers, at: expectedTimestamp, to: sut)

        expect(sut,
               toRetrieve: .success(CachedBurgers(burgers: expectedBurgers,
                                                       timestamp: expectedTimestamp)),
               file: file,
               line: line)
    }
    
    func assertRetreiveHasNoSideEffectsOnNonEmptyCache(for sut: BurgerStore, file: StaticString = #file, line: UInt = #line) {
        let expectedBurgers = uniqueBurgers().localItems
        let expectedTimestamp = Date()

        insert(expectedBurgers, at: expectedTimestamp, to: sut)

        expect(sut,
               toRetrieveTwiceWith: .success(CachedBurgers(burgers: expectedBurgers,
                                                                timestamp: expectedTimestamp)),
               file: file,
               line: line)
    }
    
    func assertInsertOverridesPreviouslyInsertedValues(for sut: BurgerStore, file: StaticString = #file, line: UInt = #line) {
        // When
        let firstInsertionError = insert(uniqueBurgers().localItems, at: Date(), to: sut)
        XCTAssertNil(firstInsertionError, file: file, line: line)

        // Given
        let latestBurgers = uniqueBurgers().localItems
        let latestTimestamp = Date()
        let latestInsertionError = insert(latestBurgers, at: latestTimestamp, to: sut)
        XCTAssertNil(latestInsertionError, file: file, line: line)

        // Then
        expect(sut,
               toRetrieve: .success(CachedBurgers(burgers: latestBurgers,
                                                           timestamp: latestTimestamp)),
               file: file,
               line: line)
    }
    
    func assertDeleteEmptiesPreviouslyInsertedCache(for sut: BurgerStore, file: StaticString = #file, line: UInt = #line) {
        insert(uniqueBurgers().localItems, at: Date(), to: sut)
        
        let deletionError = deleteCache(from: sut)
        XCTAssertNil(deletionError, file: file, line: line)

        expect(sut, toRetrieve: .success(.none), file: file, line: line)
    }
}

extension BurgerStoreSpecs where Self: XCTestCase  {
    
    func expect(_ sut: BurgerStore,
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
    
    func expect(_ sut: BurgerStore,
                toRetrieveTwiceWith expectedResult: Result<CachedBurgers?, Error>,
                file: StaticString = #file,
                line: UInt = #line) {
        expect(sut, toRetrieve: expectedResult, file: file, line: line)
        expect(sut, toRetrieve: expectedResult, file: file, line: line)
    }
    
    @discardableResult
    func deleteCache(from sut: BurgerStore) -> Error? {
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
    func insert(_ burgers: [LocalBurger], at timestamp: Date, to sut: BurgerStore) -> Error? {
        let exp = expectation(description: "wait for cache insetion")
        
        var insertionError: Error?
        sut.insert(burgers, timestamp: timestamp) { receivedError in
            insertionError = receivedError
            exp.fulfill()
        }
        wait(for: [exp], timeout: 0.1)
        
        return insertionError
    }
}
