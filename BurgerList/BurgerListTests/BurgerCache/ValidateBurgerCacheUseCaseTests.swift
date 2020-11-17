//
//  ValidateBurgerCacheUseCaseTests.swift
//  BurgerListTests
//
//  Created by Tavo on 27/10/20.
//  Copyright © 2020 Gustavo Londono. All rights reserved.
//

import XCTest
import BurgerList

class ValidateBurgerCacheUseCaseTests: XCTestCase {

    func test_init_doesnotMessageStoreUponCreation() {
        let (_, store) = makeSUT()

        XCTAssertEqual(store.receivedMessages, [])
    }

    func test_validateCache_deletesCacheOnRetreivalError() {
        let (sut, store) = makeSUT()

        sut.validateCache()
        store.completeRetreival(with: anyError)

        XCTAssertEqual(store.receivedMessages, [.retreiveCache, .deleteCachedFeed])
    }

    func test_validateCache_doesNotDeleteCacheOnEmptyCache() {
        let (sut, store) = makeSUT()

        sut.validateCache()
        store.completeRetreivalWithEmptyCache()

        XCTAssertEqual(store.receivedMessages, [.retreiveCache])
    }

    func test_validate_doesNotDeletesCacheOnNonExpiredCache() {
        let fixedCurrentDate = Date()
        let lessThanTwoWeekTimestamp = fixedCurrentDate.minusBurgerCacheMaxAge().adding(seconds: 1)
        let burgerList = uniqueBurgers()

        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })

        sut.validateCache()
        store.completeRetreival(with: burgerList.localItems, timestamp: lessThanTwoWeekTimestamp)

        XCTAssertEqual(store.receivedMessages, [.retreiveCache])
    }

    func test_load_deletesCacheOnExpiringCache() {
        let fixedCurrentDate = Date()
        let expiringTimestamp = fixedCurrentDate.minusBurgerCacheMaxAge()
        let burgerList = uniqueBurgers()

        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })

        sut.validateCache()
        store.completeRetreival(with: burgerList.localItems, timestamp: expiringTimestamp)

        XCTAssertEqual(store.receivedMessages, [.retreiveCache, .deleteCachedFeed])
    }


    func test_load_deletesCacheOnExpiredCache() {
        let fixedCurrentDate = Date()
        let expiredTimestamp = fixedCurrentDate.minusBurgerCacheMaxAge().adding(seconds: -1)
        let burgerList = uniqueBurgers()

        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })

        sut.validateCache()
        store.completeRetreival(with: burgerList.localItems, timestamp: expiredTimestamp)

        XCTAssertEqual(store.receivedMessages, [.retreiveCache, .deleteCachedFeed])
    }

    func test_validate_doesNotDeleteCacheAfterSUTInstanceHasBeenDeallocated() {
        let store = BurgerStoreSpy()
        var sut: LocalBurgerLoader? = LocalBurgerLoader(store: store, currentDate: Date.init)

        sut?.validateCache()

        sut = nil
        store.completeRetreival(with: anyError)

        XCTAssertEqual(store.receivedMessages, [.retreiveCache])
    }

    // MARK: - Helpers
    private func makeSUT(currentDate: @escaping () -> Date = Date.init,
                         file: StaticString = #file,
                         line: UInt = #line) -> (sut: LocalBurgerLoader, store: BurgerStoreSpy) {
        let store = BurgerStoreSpy()
        let sut = LocalBurgerLoader(store: store, currentDate: currentDate)

        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)

        return (sut: sut, store: store)
    }
}
