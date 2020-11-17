//
//  CacheFeedUseCaseTests.swift
//  BurgerListTests
//
//  Created by Gustavo Londono on 8/14/20.
//  Copyright © 2020 Gustavo Londono. All rights reserved.
//

import XCTest
@testable import BurgerList

class CacheFeedUseCaseTests: XCTestCase {
    
    func test_init_doesNotMessageStoreCacheUponCreation() {
        let (_, store) = createSUT()
        
        XCTAssertEqual(store.receivedMessages, [])
    }
    
    func test_save_requestCacheDeletion() {
        let (sut, store) = createSUT()
        
        sut.save(uniqueBurgers().models) { _ in }
        
        XCTAssertEqual(store.receivedMessages, [.deleteCachedFeed])
    }
    
    func test_save_doesNotRequestCacheInsertionOnDeletionError() {
        let (sut, store) = createSUT()
        let items = uniqueBurgers().models
        
        sut.save(items) { _ in }
        
        store.completeDeletion(with: anyError)
        
        XCTAssertEqual(store.receivedMessages, [.deleteCachedFeed])
    }
    
    func test_save_requestCacheInsertionWithTimestampOnDeletionSuccess() {
        let timestamp = Date()
        let (sut, store) = createSUT(currentDate: { timestamp })
        let items = uniqueBurgers()
        
        sut.save(items.models) { _ in }
        
        store.completeDeletionSuccessfully()
        
        XCTAssertEqual(store.receivedMessages, [.deleteCachedFeed, .insert(items.localItems, timestamp)])
    }
    
    func test_save_failsDeletionError() {
        let (sut, store) = createSUT()
        let deletionError = anyError
        
        expect(sut: sut, toCompleteWith: deletionError) {
            store.completeDeletion(with: deletionError)
        }
    }
    
    func test_save_failsInsertionError() {
        let (sut, store) = createSUT()
        let insertionError = anyError
        
        expect(sut: sut, toCompleteWith: insertionError) {
            store.completeDeletionSuccessfully()
            store.completeInsertion(with: insertionError)
        }
    }
    
    func test_save_succeedsOnSucessfulInsertion() {
        let (sut, store) = createSUT()
        
        expect(sut: sut, toCompleteWith: nil) {
            store.completeDeletionSuccessfully()
            store.completeInsertionSuccessfully()
        }
    }
    
    func test_save_doesNotDeliverDeletionErrorAfterSUTInstanceHasBeenDeallocated() {
        let store = BurgerStoreSpy()
        var sut: LocalBurgerLoader? = LocalBurgerLoader(store: store, currentDate: Date.init)
        
        var capturedError: Error?
        sut?.save(uniqueBurgers().models, completion: { error in
            capturedError = error
        })
        
        sut = nil
        store.completeDeletion(with: anyError)
        
        XCTAssertNil(capturedError)
    }
    
    func test_save_doesNotDeliverInsertionErrorAfterSUTInstanceHasBeenDeallocated() {
        let store = BurgerStoreSpy()
        var sut: LocalBurgerLoader? = LocalBurgerLoader(store: store, currentDate: Date.init)
        
        var capturedError: Error?
        sut?.save([uniqueBurger], completion: { error in
            capturedError = error
        })
        
        store.completeDeletionSuccessfully()
        sut = nil
        store.completeInsertion(with: anyError)
        
        XCTAssertNil(capturedError)
    }
    
    // MARK: - Helpers
    private func expect(sut: LocalBurgerLoader,
                        toCompleteWith error: NSError?,
                        file: StaticString = #file,
                        line: UInt = #line,
                        when action: () -> Void) {
        let exp = expectation(description: "Wait for save completion")
        
        var receivedError: Error?
        sut.save(uniqueBurgers().models) { error in
            receivedError = error
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1)
        
        XCTAssertEqual(receivedError as NSError?, error)
    }
    
    private func createSUT(currentDate: @escaping () -> Date = Date.init,
                           file: StaticString = #file,
                           line: UInt = #line) -> (sut: LocalBurgerLoader, store: BurgerStoreSpy) {
        let store = BurgerStoreSpy()
        let sut = LocalBurgerLoader(store: store, currentDate: currentDate)
        
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (sut: sut, store: store)
    }
}
