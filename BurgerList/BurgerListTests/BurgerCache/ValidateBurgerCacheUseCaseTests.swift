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

    func test_validate_doesNotDeletesCacheOnLessThanTwoWeeksOldCache() {
        let fixedCurrentDate = Date()
        let lessThanTwoWeekTimestamp = fixedCurrentDate.adding(days: -14).adding(seconds: 1)
        let burgerList = uniqueItems()

        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })

        sut.validateCache()
        store.completeRetreival(with: burgerList.localItems, timestamp: lessThanTwoWeekTimestamp)

        XCTAssertEqual(store.receivedMessages, [.retreiveCache])
    }

    func test_load_deletesCacheOnTwoWeeksOldCache() {
        let fixedCurrentDate = Date()
        let lessThanTwoWeekTimestamp = fixedCurrentDate.adding(days: -14)
        let burgerList = uniqueItems()

        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })

        sut.validateCache()
        store.completeRetreival(with: burgerList.localItems, timestamp: lessThanTwoWeekTimestamp)

        XCTAssertEqual(store.receivedMessages, [.retreiveCache, .deleteCachedFeed])
    }


    func test_load_deletesCacheOnMoreThanTwoWeeksOldCache() {
        let fixedCurrentDate = Date()
        let lessThanTwoWeekTimestamp = fixedCurrentDate.adding(days: -14).adding(seconds: -1)
        let burgerList = uniqueItems()

        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })

        sut.validateCache()
        store.completeRetreival(with: burgerList.localItems, timestamp: lessThanTwoWeekTimestamp)

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

    private var uniqueItem: Burger {
        return Burger(id: UUID(), name: "a name", description: "a description", imageURL: anyURL)
    }

    private func uniqueItems() -> (models: [Burger], localItems: [LocalBurger]) {
        let items = [uniqueItem, uniqueItem]
        let localItems = items.map { LocalBurger(id: $0.id, name: $0.name, description: $0.description, imageURL: $0.imageURL) }

        return (models: items, localItems: localItems)
    }
}
