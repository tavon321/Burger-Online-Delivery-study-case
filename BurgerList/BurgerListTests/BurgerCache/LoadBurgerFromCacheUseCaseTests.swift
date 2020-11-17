//
//  LoadBurgerFromCacheTests.swift
//  BurgerListTests
//
//  Created by Gustavo Londono on 9/16/20.
//  Copyright © 2020 Gustavo Londono. All rights reserved.
//

import XCTest
import BurgerList

class LoadBurgerFromCacheUseCaseTests: XCTestCase {
    
    func test_init_doesnotMessageStoreUponCreation() {
        let (_, store) = makeSUT()
        
        XCTAssertEqual(store.receivedMessages, [])
    }
    
    func test_load_requestCacheRetreival() {
        let (sut, store) = makeSUT()
        
        sut.load { _ in }
        
        XCTAssertEqual(store.receivedMessages, [.retreiveCache])
    }
    
    func test_load_failsErrorOnStoreError() {
        let (sut, store) = makeSUT()
        let expectedError = anyError

        expect(sut, toCompleteWith: .failure(expectedError)) {
            store.completeRetreival(with: expectedError)
        }
    }
    
    func test_load_deliversNoBurgersOnEmptyCache() {
        let (sut, store) = makeSUT()
        let emptyBurgers = [Burger]()
        
        expect(sut, toCompleteWith: .success(emptyBurgers)) {
            store.completeRetreivalWithEmptyCache()
        }
    }
    
    func test_load_deliversBurgersOnNonExpiredCache() {
        let fixedCurrentDate = Date()
        let nonExpiredTimestamp = fixedCurrentDate.minusBurgerCacheMaxAge().adding(seconds: 1)
        let burgerList = uniqueItems()
        
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })
        
        expect(sut, toCompleteWith: .success(burgerList.models)) {
            store.completeRetreival(with: burgerList.localItems, timestamp: nonExpiredTimestamp)
        }
    }

    func test_load_deliversNoBurgersOnExpirationDate() {
        let fixedCurrentDate = Date()
        let expirationTimestamp = fixedCurrentDate.minusBurgerCacheMaxAge()
        let burgerList = uniqueItems()
        
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })
        
        expect(sut, toCompleteWith: .success([])) {
            store.completeRetreival(with: burgerList.localItems, timestamp: expirationTimestamp)
        }
    }
    
    func test_load_deliversNoBurgersOnMoreThanExpiredCache() {
        let fixedCurrentDate = Date()
        let expirationTimestamp = fixedCurrentDate.minusBurgerCacheMaxAge().adding(seconds: -1)
        let burgerList = uniqueItems()
        
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })
        
        expect(sut, toCompleteWith: .success([])) {
            store.completeRetreival(with: burgerList.localItems, timestamp: expirationTimestamp)
        }
    }
    
    func test_load_hasNotSideEffectsOnRetreivalError() {
        let (sut, store) = makeSUT()
        
        sut.load { _ in }
        store.completeRetreivalWithEmptyCache()
        
        XCTAssertEqual(store.receivedMessages, [.retreiveCache])
    }
    
    func test_load_hasNoSideEffectsOnEmptyCache() {
        let (sut, store) = makeSUT()
        
        sut.load { _ in }
        store.completeRetreivalWithEmptyCache()
        
        XCTAssertEqual(store.receivedMessages, [.retreiveCache])
    }
    
    func test_load_hasNoSideEffectOnNonExpiredCache() {
        let fixedCurrentDate = Date()
        let nonExpiredTimestamp = fixedCurrentDate.minusBurgerCacheMaxAge().adding(seconds: 1)
        let burgerList = uniqueItems()
        
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })
        
        sut.load { _ in }
        store.completeRetreival(with: burgerList.localItems, timestamp: nonExpiredTimestamp)
        
        XCTAssertEqual(store.receivedMessages, [.retreiveCache])
    }
    
    func test_load_hasNoSideEffectsOnExpiredCache() {
        let fixedCurrentDate = Date()
        let expiredTimestamp = fixedCurrentDate.minusBurgerCacheMaxAge()
        let burgerList = uniqueItems()
        
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })
        
        sut.load { _ in }
        store.completeRetreival(with: burgerList.localItems, timestamp: expiredTimestamp)
        
        XCTAssertEqual(store.receivedMessages, [.retreiveCache])
    }

    func test_load_hasNoSideEffectsOnMoreThanExpiredCache() {
        let fixedCurrentDate = Date()
        let expiredTimestamp = fixedCurrentDate.minusBurgerCacheMaxAge().adding(seconds: -1)
        let burgerList = uniqueItems()

        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })

        sut.load { _ in }
        store.completeRetreival(with: burgerList.localItems, timestamp: expiredTimestamp)

        XCTAssertEqual(store.receivedMessages, [.retreiveCache])
    }
    
    func test_load_doesNotDeliverResultAfterSUTInstanceHasBeenDeallocated() {
        let store = BurgerStoreSpy()
        var sut: LocalBurgerLoader? = LocalBurgerLoader(store: store, currentDate: Date.init)
        
        var capturedResult = [BurgerLoader.Result]()
        sut?.load { capturedResult.append($0) }
        
        sut = nil
        store.completeRetreivalWithEmptyCache()
        
        XCTAssertTrue(capturedResult.isEmpty)
    }
    
    // MARK: - Helpers
    private func expect(_ sut: LocalBurgerLoader,
                        toCompleteWith expectedResult: BurgerLoader.Result,
                        file: StaticString = #file,
                        line: UInt = #line,
                        when action: () -> Void) {
        
        let exp = expectation(description: "Wait for result")
        sut.load { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedBurgers), .success(expectedBurgers)):
                XCTAssertEqual(receivedBurgers, expectedBurgers, file: file, line: line)
            case let (.failure(receivedError as NSError), .failure(expectedError as NSError)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)
            default:
               XCTFail("Expected \(expectedResult), got \(receivedResult) instead")
            }
            exp.fulfill()
        }

        action()
        
        wait(for: [exp], timeout: 0.1)
        
    }
    
    private func makeSUT(currentDate: @escaping () -> Date = Date.init,
                         file: StaticString = #file,
                         line: UInt = #line) -> (sut: LocalBurgerLoader, store: BurgerStoreSpy) {
        let store = BurgerStoreSpy()
        let sut = LocalBurgerLoader(store: store, currentDate: currentDate)
        
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (sut: sut, store: store)
    }
    
    private var uniqueItem: Burger {
        return Burger(id: UUID(), name: "a name", description: "a description", imageURL: anyURL)
    }
    
    private func uniqueItems() -> (models: [Burger], localItems: [LocalBurger]) {
        let items = [uniqueItem, uniqueItem]
        let localItems = items.map { LocalBurger(id: $0.id, name: $0.name, description: $0.description, imageURL: $0.imageURL) }
        
        return (models: items, localItems: localItems)
    }
    
}
